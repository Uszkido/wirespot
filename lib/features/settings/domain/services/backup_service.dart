import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/vpn/wireguard_vpn_service.dart';
import '../entities/app_settings.dart';
import '../entities/backup_payload.dart';
import '../entities/printer_config_entity.dart';
import '../repositories/settings_repository.dart';

class BackupService {
  const BackupService({
    required SettingsRepository repository,
    required AppDatabase database,
    required WireGuardVpnService wireGuardVpnService,
  }) : _repository = repository,
       _database = database,
       _wireGuardVpnService = wireGuardVpnService;

  final SettingsRepository _repository;
  final AppDatabase _database;
  final WireGuardVpnService _wireGuardVpnService;

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
    final groups = await _database.select(_database.routerGroups).get();
    final wgConfigs = await _wireGuardVpnService.getSavedTunnels();

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
      routers: [
        for (final r in routers)
          {
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
            'createdAt': r.createdAt.toIso8601String(),
          },
      ],
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
