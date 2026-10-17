/// Organization-scoped state used by the lightweight backend.
/// Each request is kept isolated by its organization id.
class BackendStore {
  BackendStore._();

  static final _vouchers = <String, List<Map<String, dynamic>>>{};
  static final _routers = <String, List<Map<String, dynamic>>>{};
  static final _backups = <String, Map<String, dynamic>>{};
  static final _backupTimes = <String, DateTime>{};
  static final _telemetryEvents = <String, int>{};
  static final _entitlements = <String, Map<String, dynamic>>{};
  static final _commands = <String, List<Map<String, dynamic>>>{};

  static List<Map<String, dynamic>> vouchersFor(String orgId) =>
      _vouchers.putIfAbsent(orgId, () => <Map<String, dynamic>>[]);

  static List<Map<String, dynamic>> routersFor(String orgId) =>
      _routers.putIfAbsent(orgId, () => <Map<String, dynamic>>[]);

  static Map<String, dynamic>? latestBackupFor(String orgId) => _backups[orgId];

  static DateTime? latestBackupAtFor(String orgId) => _backupTimes[orgId];

  static void saveBackup(String orgId, Map<String, dynamic> backup) {
    _backups[orgId] = backup;
    _backupTimes[orgId] = DateTime.now().toUtc();
  }

  static int incrementTelemetry(String orgId) {
    final count = (_telemetryEvents[orgId] ?? 0) + 1;
    _telemetryEvents[orgId] = count;
    return count;
  }

  static Map<String, dynamic>? entitlementFor(String orgId) =>
      _entitlements[orgId];

  static void saveEntitlement(String orgId, Map<String, dynamic> value) {
    _entitlements[orgId] = value;
  }

  static List<Map<String, dynamic>> commandsFor(String orgId) =>
      _commands.putIfAbsent(orgId, () => <Map<String, dynamic>>[]);

  static void enqueueCommand(String orgId, Map<String, dynamic> command) {
    commandsFor(orgId).add(command);
  }

  static Map<String, dynamic>? commandFor(String orgId, String commandId) {
    final commands = commandsFor(orgId);
    for (final command in commands) {
      if (command['id'] == commandId) return command;
    }
    return null;
  }
}
