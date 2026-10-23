import 'dart:convert';
import 'dart:io';

/// Organization-scoped state with an atomic JSON snapshot for restart-safe
/// single-instance deployments. Configure WIRESPOT_STORE_PATH to a persistent
/// volume in production; use Firestore before running multiple instances.
class BackendStore {
  BackendStore._();
  static final _vouchers = <String, List<Map<String, dynamic>>>{};
  static final _routers = <String, List<Map<String, dynamic>>>{};
  static final _backups = <String, Map<String, dynamic>>{};
  static final _backupTimes = <String, DateTime>{};
  static final _telemetryEvents = <String, int>{};
  static final _entitlements = <String, Map<String, dynamic>>{};
  static final _commands = <String, List<Map<String, dynamic>>>{};
  static final _pairingCodes = <String, Map<String, dynamic>>{};
  static final _accounts = <String, Map<String, dynamic>>{};
  static final _path =
      Platform.environment['WIRESPOT_STORE_PATH'] ?? '.wirespot/store.json';
  static bool _loaded = false;

  static void _ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    final file = File(_path);
    if (!file.existsSync()) return;
    try {
      final root = jsonDecode(file.readAsStringSync());
      if (root is! Map) return;
      _readLists(root['vouchers'], _vouchers);
      _readLists(root['routers'], _routers);
      _readLists(root['commands'], _commands);
      _readMaps(root['backups'], _backups);
      _readMaps(root['entitlements'], _entitlements);
      _readMaps(root['accounts'], _accounts);
      if (root['backupTimes'] is Map) {
        for (final e in (root['backupTimes'] as Map).entries) {
          final value = DateTime.tryParse(e.value.toString());
          if (value != null) _backupTimes[e.key.toString()] = value;
        }
      }
      if (root['telemetryEvents'] is Map) {
        for (final e in (root['telemetryEvents'] as Map).entries) {
          _telemetryEvents[e.key.toString()] = e.value is num
              ? (e.value as num).toInt()
              : int.tryParse(e.value.toString()) ?? 0;
        }
      }
    } on Object {
      // Ignore a corrupt snapshot and allow the service to start cleanly.
    }
  }

  static void _readLists(
      Object? value, Map<String, List<Map<String, dynamic>>> target) {
    if (value is! Map) return;
    for (final e in value.entries) {
      if (e.value is List) {
        target[e.key.toString()] = (e.value as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
  }

  static void _readMaps(
      Object? value, Map<String, Map<String, dynamic>> target) {
    if (value is! Map) return;
    for (final e in value.entries) {
      if (e.value is Map)
        target[e.key.toString()] = Map<String, dynamic>.from(e.value as Map);
    }
  }

  static List<Map<String, dynamic>> vouchersFor(String orgId) {
    _ensureLoaded();
    return _vouchers.putIfAbsent(orgId, () => <Map<String, dynamic>>[]);
  }

  static List<Map<String, dynamic>> routersFor(String orgId) {
    _ensureLoaded();
    return _routers.putIfAbsent(orgId, () => <Map<String, dynamic>>[]);
  }

  /// Merge router inventory from a device without deleting routers that were
  /// created by another device in the same workspace. A full replacement is
  /// available to explicit administrative restore flows.
  static int mergeRouters(
    String orgId,
    Iterable<Map<String, dynamic>> incoming, {
    bool replace = false,
  }) {
    final stored = routersFor(orgId);
    if (replace) stored.clear();
    var merged = 0;
    for (final router in incoming) {
      final key = _routerKey(router);
      if (key == null) continue;
      final index = stored.indexWhere((item) => _routerKey(item) == key);
      if (index >= 0) {
        stored[index] = router;
      } else {
        stored.add(router);
      }
      merged++;
    }
    persist();
    return merged;
  }

  static String? _routerKey(Map<String, dynamic> router) {
    final value =
        router['id'] ?? router['routerId'] ?? router['ip'] ?? router['host'];
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim().toLowerCase();
  }

  static Map<String, dynamic>? latestBackupFor(String orgId) {
    _ensureLoaded();
    return _backups[orgId];
  }

  static DateTime? latestBackupAtFor(String orgId) {
    _ensureLoaded();
    return _backupTimes[orgId];
  }

  static void saveBackup(String orgId, Map<String, dynamic> backup) {
    _ensureLoaded();
    _backups[orgId] = backup;
    _backupTimes[orgId] = DateTime.now().toUtc();
    persist();
  }

  static Map<String, dynamic>? accountFor(String email) {
    _ensureLoaded();
    return _accounts[email.trim().toLowerCase()];
  }

  static void saveAccount(String email, Map<String, dynamic> account) {
    _ensureLoaded();
    _accounts[email.trim().toLowerCase()] = Map<String, dynamic>.from(account);
    persist();
  }

  static int incrementTelemetry(String orgId) {
    _ensureLoaded();
    final count = (_telemetryEvents[orgId] ?? 0) + 1;
    _telemetryEvents[orgId] = count;
    persist();
    return count;
  }

  static Map<String, dynamic>? entitlementFor(String orgId) {
    _ensureLoaded();
    return _entitlements[orgId];
  }

  static void saveEntitlement(String orgId, Map<String, dynamic> value) {
    _ensureLoaded();
    _entitlements[orgId] = value;
    persist();
  }

  static List<Map<String, dynamic>> commandsFor(String orgId) {
    _ensureLoaded();
    return _commands.putIfAbsent(orgId, () => <Map<String, dynamic>>[]);
  }

  static void enqueueCommand(String orgId, Map<String, dynamic> command) {
    commandsFor(orgId).add(command);
    persist();
  }

  static Map<String, dynamic>? commandFor(String orgId, String commandId) =>
      commandsFor(orgId)
          .cast<Map<String, dynamic>?>()
          .firstWhere((c) => c?['id'] == commandId, orElse: () => null);

  static String createPairingCode(String orgId) {
    final code =
        'WS-${DateTime.now().microsecondsSinceEpoch.toString().substring(7)}-SYNC';
    _pairingCodes[code] = {
      'organizationId': orgId,
      'expiresAt': DateTime.now()
          .toUtc()
          .add(const Duration(minutes: 10))
          .toIso8601String(),
    };
    return code;
  }

  static String? consumePairingCode(String code) {
    final entry = _pairingCodes.remove(code.trim().toUpperCase());
    if (entry == null) return null;
    final expiry = DateTime.tryParse(entry['expiresAt']?.toString() ?? '');
    if (expiry == null || !expiry.isAfter(DateTime.now().toUtc())) return null;
    return entry['organizationId']?.toString();
  }

  /// Persist after callers mutate a list returned by this store.
  static void persist() {
    _ensureLoaded();
    try {
      final file = File(_path);
      file.parent.createSync(recursive: true);
      final temp = File('$_path.tmp');
      temp.writeAsStringSync(jsonEncode({
        'vouchers': _vouchers,
        'routers': _routers,
        'backups': _backups,
        'backupTimes':
            _backupTimes.map((k, v) => MapEntry(k, v.toIso8601String())),
        'telemetryEvents': _telemetryEvents,
        'entitlements': _entitlements,
        'accounts': _accounts,
        'commands': _commands,
      }));
      if (file.existsSync()) file.deleteSync();
      temp.renameSync(_path);
    } on Object {
      // Read-only filesystems continue operating with in-memory state.
    }
  }
}
