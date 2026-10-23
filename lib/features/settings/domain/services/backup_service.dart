import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/vpn/wireguard_vpn_service.dart';
import '../../../hotspot/domain/services/hotspot_service.dart';
import '../../../routers/domain/entities/router_entity.dart';
import '../entities/app_settings.dart';
import '../entities/backup_payload.dart';
import '../entities/printer_config_entity.dart';
import '../repositories/settings_repository.dart';

class BackupService {
  const BackupService({
    required SettingsRepository repository,
    required AppDatabase database,
    required WireGuardVpnService wireGuardVpnService,
    HotspotService? hotspotService,
  }) : _repository = repository,
       _database = database,
       _wireGuardVpnService = wireGuardVpnService,
       _hotspotService = hotspotService;

  final SettingsRepository _repository;
  final AppDatabase _database;
  final WireGuardVpnService _wireGuardVpnService;
  final HotspotService? _hotspotService;

  Future<BackupPayload> buildBackup() async {
    final printers = await _repository.getPrinters();
    final settings = <String, String>{};
    for (final key in [
      AppSettingsKeys.themeMode,
      AppSettingsKeys.languageCode,
      AppSettingsKeys.currencyCode,
      AppSettingsKeys.notificationsEnabled,
      AppSettingsKeys.businessName,
      AppSettingsKeys.businessEmail,
      AppSettingsKeys.businessPhone,
      AppSettingsKeys.businessWebsite,
      AppSettingsKeys.businessLogoPath,
    ]) {
      final value = await _repository.readSetting(key);
      if (value != null) {
        settings[key] = value;
      }
    }

    final routers = await _database.select(_database.routers).get();
    final profiles = await _database.select(_database.hotspotProfiles).get();
    final voucherHistory = await _database
        .select(_database.voucherHistory)
        .get();
    final groups = await _database.select(_database.routerGroups).get();
    final wgConfigs = await _wireGuardVpnService.getSavedTunnels();

    final routerSnapshots = <Map<String, Object?>>[];
    final hotspotUsers = <Map<String, Object?>>[];
    final sessionSnapshots = <Map<String, Object?>>[];
    for (final r in routers) {
      final snapshot = <String, Object?>{
        'id': r.id,
        'groupId': r.groupId,
        'vendor': r.vendor,
        'name': r.name,
        'host': r.host,
        'apiPort': r.apiPort,
        'useSsl': r.useSsl,
        'requireVpn': r.requireVpn,
        'remoteAccessMode': r.remoteAccessMode,
        'username': r.username,
        'identity': r.identity,
        'version': r.version,
        'boardName': r.boardName,
        'isEnabled': r.isEnabled,
        'lastConnectedAt': r.lastConnectedAt?.toUtc().toIso8601String(),
        'createdAt': r.createdAt.toIso8601String(),
      };
      final hotspotService = _hotspotService;
      if (hotspotService != null) {
        try {
          final entity = _routerEntityFromRecord(r);
          final users = await hotspotService.getUsers(entity);
          hotspotUsers.addAll(
            users.map(
              (user) => {
                'id': user.id,
                'syncKey': '${r.id}:${user.id}',
                'routerId': r.id,
                'routerName': r.name,
                'username': user.name,
                'profile': user.profile,
                'server': user.server,
                'comment': user.comment,
                'disabled': user.disabled,
                'uptime': user.uptime,
                'bytesIn': user.bytesIn,
                'bytesOut': user.bytesOut,
                'limitUptime': user.limitUptime,
                'limitBytesTotal': user.limitBytesTotal,
              },
            ),
          );
        } on Object {
          // A user listing failure should not hide router health or sessions.
        }
        try {
          final entity = _routerEntityFromRecord(r);
          final activeSessions = await hotspotService.getActiveSessions(entity);
          sessionSnapshots.addAll(
            activeSessions.map(
              (session) => {
                'id': session.id,
                'syncKey': '${r.id}:${session.id}',
                'routerId': r.id,
                'routerName': r.name,
                'username': session.user,
                'address': session.address,
                'macAddress': session.macAddress,
                'uptime': session.uptime,
                'sessionTimeLeft': session.sessionTimeLeft,
                'bytesIn': session.bytesIn,
                'bytesOut': session.bytesOut,
                'loginBy': session.loginBy,
                'server': session.server,
              },
            ),
          );
          snapshot['status'] = 'online';
          snapshot['users'] = activeSessions.length;
          snapshot['lastConnectedAt'] = DateTime.now()
              .toUtc()
              .toIso8601String();
        } on Object {
          snapshot['status'] = 'offline';
          snapshot['users'] = 0;
        }
      }
      routerSnapshots.add(snapshot);
    }

    return BackupPayload(
      version: 1,
      exportedAt: DateTime.now(),
      settings: settings,
      printers: [
        for (final printer in printers)
          {
            'id': printer.id,
            'name': printer.name,
            'address': printer.address,
            'paperWidthMm': printer.paperWidthMm,
            'isDefault': printer.isDefault,
          },
      ],
      routers: routerSnapshots,
      hotspotProfiles: [
        for (final p in profiles)
          {
            'id': p.id,
            'routerId': p.routerId,
            'name': p.name,
            'rateLimit': p.rateLimit,
            'validityMinutes': p.validityMinutes,
            'priceMinor': p.priceMinor,
            'currency': p.currency,
            'createdAt': p.createdAt.toIso8601String(),
          },
      ],
      hotspotUsers: hotspotUsers,
      sessions: sessionSnapshots,
      vouchers: [
        for (final voucher in voucherHistory)
          {
            'id': voucher.id,
            'routerId': voucher.routerId,
            'username': voucher.username,
            'code': voucher.username,
            'profileId': voucher.profileId,
            'priceMinor': voucher.priceMinor,
            'currency': voucher.currency,
            'validityMinutes': voucher.validityMinutes,
            'generatedAt': voucher.generatedAt.toUtc().toIso8601String(),
            'printedAt': voucher.printedAt?.toUtc().toIso8601String(),
            'soldAt': voucher.soldAt?.toUtc().toIso8601String(),
            'note': voucher.note,
          },
      ],
      routerGroups: [
        for (final g in groups)
          {
            'id': g.id,
            'name': g.name,
            'createdAt': g.createdAt.toIso8601String(),
          },
      ],
      wireGuardConfigs: [
        for (final wg in wgConfigs) {'name': wg.name, 'config': wg.config},
      ],
    );
  }

  Future<void> restoreBackup(BackupPayload payload) async {
    for (final entry in payload.settings.entries) {
      await _repository.writeSetting(entry.key, entry.value);
    }

    for (final printer in payload.printers) {
      final id = printer['id']?.toString();
      final name = printer['name']?.toString();
      final address = printer['address']?.toString();
      if (id == null ||
          id.trim().isEmpty ||
          name == null ||
          name.trim().isEmpty ||
          address == null ||
          address.trim().isEmpty) {
        continue;
      }
      await _repository.savePrinter(
        PrinterConfigEntity(
          id: id,
          name: name,
          address: address,
          paperWidthMm: _intValue(printer['paperWidthMm']) ?? 58,
          isDefault: _boolValue(printer['isDefault']),
        ),
      );
    }

    for (final r in payload.routers) {
      final id = r['id']?.toString();
      final name = r['name']?.toString();
      final host = r['host']?.toString();
      if (id == null || name == null || host == null) {
        continue;
      }
      await _database
          .into(_database.routers)
          .insertOnConflictUpdate(
            RoutersCompanion.insert(
              id: id,
              name: name,
              host: host,
              groupId: Value(r['groupId']?.toString()),
              vendor: Value(r['vendor']?.toString() ?? 'mikrotik'),
              apiPort: Value(_intValue(r['apiPort'] ?? r['port']) ?? 8728),
              useSsl: Value(_boolValue(r['useSsl'])),
              requireVpn: Value(_boolValue(r['requireVpn'])),
              remoteAccessMode: Value(
                r['remoteAccessMode']?.toString() ?? 'wireGuard',
              ),
              username: r['username']?.toString() ?? 'admin',
              identity: Value(r['identity']?.toString()),
              version: Value(r['version']?.toString()),
              boardName: Value(r['boardName']?.toString()),
              isEnabled: Value(_boolValue(r['isEnabled'] ?? true)),
              createdAt: Value(
                DateTime.tryParse(r['createdAt']?.toString() ?? '') ??
                    DateTime.now(),
              ),
            ),
          );
    }

    for (final p in payload.hotspotProfiles) {
      final id = p['id']?.toString();
      final name = p['name']?.toString();
      final routerId = p['routerId']?.toString();
      if (id == null || name == null) {
        continue;
      }
      await _database
          .into(_database.hotspotProfiles)
          .insertOnConflictUpdate(
            HotspotProfilesCompanion.insert(
              id: id,
              routerId: routerId ?? 'default',
              name: name,
              rateLimit: Value(p['rateLimit']?.toString()),
              validityMinutes: Value(
                _intValue(p['validityMinutes'] ?? p['validitySeconds']),
              ),
              priceMinor: Value(_intValue(p['priceMinor'] ?? p['price']) ?? 0),
              currency: Value(p['currency']?.toString() ?? 'NGN'),
              createdAt: Value(
                DateTime.tryParse(p['createdAt']?.toString() ?? '') ??
                    DateTime.now(),
              ),
            ),
          );
    }

    for (final g in payload.routerGroups) {
      final id = g['id']?.toString();
      final name = g['name']?.toString();
      if (id == null || name == null) {
        continue;
      }
      await _database
          .into(_database.routerGroups)
          .insertOnConflictUpdate(
            RouterGroupsCompanion.insert(
              id: id,
              name: name,
              createdAt: Value(
                DateTime.tryParse(g['createdAt']?.toString() ?? '') ??
                    DateTime.now(),
              ),
            ),
          );
    }

    for (final wg in payload.wireGuardConfigs) {
      final configStr = wg['config']?.toString();
      if (configStr != null && configStr.trim().isNotEmpty) {
        await _wireGuardVpnService.importConfigString(configStr);
      }
    }
  }

  Future<File> exportBackupToFile() async {
    final payload = await buildBackup();
    final jsonStr = const JsonEncoder.withIndent(
      '  ',
    ).convert(payload.toJson());

    final documentsDir = await getApplicationDocumentsDirectory();
    final backupFile = File(p.join(documentsDir.path, 'wirespot_backup.json'));
    await backupFile.writeAsString(jsonStr);

    try {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (downloadDir.existsSync()) {
        final publicBackup = File(
          p.join(downloadDir.path, 'wirespot_backup.json'),
        );
        await publicBackup.writeAsString(jsonStr);
      }
    } on Object {
      // Best effort for external storage on Android
    }

    return backupFile;
  }

  Future<bool> importBackupFromFile() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (file == null || file.path == null) {
      return false;
    }

    final content = await File(file.path!).readAsString();
    final decoded = jsonDecode(content);
    if (decoded is! Map) {
      throw const FormatException('Backup JSON must be a valid object.');
    }

    final payload = BackupPayload.fromJson({
      for (final entry in decoded.entries) entry.key.toString(): entry.value,
    });

    await restoreBackup(payload);
    return true;
  }

  Future<bool> autoRestoreIfBackupFound() async {
    final existingRouters = await _database.select(_database.routers).get();
    if (existingRouters.isNotEmpty) {
      return false;
    }

    final candidates = <String>[];
    try {
      final docs = await getApplicationDocumentsDirectory();
      candidates.add(p.join(docs.path, 'wirespot_backup.json'));
    } on Object {
      // Ignore
    }
    candidates.addAll([
      '/storage/emulated/0/Download/wirespot_backup.json',
      '/storage/emulated/0/Documents/wirespot_backup.json',
    ]);

    for (final path in candidates) {
      final file = File(path);
      if (file.existsSync()) {
        try {
          final content = await file.readAsString();
          final decoded = jsonDecode(content);
          if (decoded is Map) {
            final payload = BackupPayload.fromJson({
              for (final entry in decoded.entries)
                entry.key.toString(): entry.value,
            });
            await restoreBackup(payload);
            return true;
          }
        } on Object {
          // Continue scanning remaining candidate files
        }
      }
    }

    return false;
  }

  int? _intValue(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  bool _boolValue(Object? value) {
    if (value is bool) {
      return value;
    }
    return value?.toString().toLowerCase() == 'true';
  }
}

RouterEntity _routerEntityFromRecord(RouterRecord record) {
  return RouterEntity(
    id: record.id,
    groupId: record.groupId,
    vendor: RouterVendor.fromName(record.vendor),
    name: record.name,
    host: record.host,
    apiPort: record.apiPort,
    useSsl: record.useSsl,
    requireVpn: record.requireVpn,
    remoteAccessMode: RouterRemoteAccessMode.fromName(
      record.remoteAccessMode,
      requireVpn: record.requireVpn,
    ),
    username: record.username,
    identity: record.identity,
    version: record.version,
    boardName: record.boardName,
    isEnabled: record.isEnabled,
    lastConnectedAt: record.lastConnectedAt,
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
  );
}
