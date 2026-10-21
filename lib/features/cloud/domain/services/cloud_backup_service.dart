import 'dart:convert';

import '../../../../core/database/app_database.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/domain/entities/backup_payload.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../settings/domain/services/backup_service.dart';
import '../../data/cloud_api_client.dart';

class CloudBackupService {
  const CloudBackupService({
    required CloudApiClient cloudApiClient,
    required BackupService backupService,
    required SettingsRepository settingsRepository,
    required AppDatabase database,
  }) : _cloudApiClient = cloudApiClient,
       _backupService = backupService,
       _settingsRepository = settingsRepository,
       _database = database;

  final CloudApiClient _cloudApiClient;
  final BackupService _backupService;
  final SettingsRepository _settingsRepository;
  final AppDatabase _database;

  Future<bool> uploadCloudBackup() async {
    final payload = await _backupService.buildBackup();
    final jsonMap = payload.toJson();
    final jsonStr = jsonEncode(jsonMap);
    final sizeBytes = utf8.encode(jsonStr).length;

    final success = await _cloudApiClient.uploadCloudBackup(jsonMap);
    if (success) {
      final nowStr = DateTime.now().toIso8601String();
      await _settingsRepository.writeSetting(
        AppSettingsKeys.lastCloudBackupAt,
        nowStr,
      );
      await _settingsRepository.writeSetting(
        AppSettingsKeys.lastCloudBackupSize,
        sizeBytes.toString(),
      );
    }
    return success;
  }

  Future<BackupPayload?> fetchLatestCloudBackup() async {
    final rawJson = await _cloudApiClient.fetchLatestCloudBackup();
    if (rawJson == null) {
      return null;
    }
    try {
      return BackupPayload.fromJson(rawJson);
    } on Object {
      return null;
    }
  }

  Future<bool> restoreFromCloud() async {
    final payload = await fetchLatestCloudBackup();
    if (payload == null) {
      return false;
    }
    await _backupService.restoreBackup(payload);
    return true;
  }

  /// Pulls the cloud snapshot, merges it with local records, restores the
  /// merged workspace, and publishes the result again. Records are merged by
  /// stable id (or name for WireGuard profiles); cloud values win conflicts,
  /// while local-only records are preserved. This makes a companion device
  /// both a consumer and a publisher of the shared workspace.
  Future<bool> syncBidirectional() async {
    final local = await _backupService.buildBackup();
    final remote = await fetchLatestCloudBackup();
    if (remote == null) {
      return uploadCloudBackup();
    }

    final merged = BackupPayload(
      version: local.version > remote.version ? local.version : remote.version,
      exportedAt: DateTime.now(),
      settings: {...local.settings, ...remote.settings},
      printers: _mergeRecords(local.printers, remote.printers),
      routers: _mergeRecords(local.routers, remote.routers),
      hotspotProfiles: _mergeRecords(
        local.hotspotProfiles,
        remote.hotspotProfiles,
      ),
      routerGroups: _mergeRecords(local.routerGroups, remote.routerGroups),
      wireGuardConfigs: _mergeRecords(
        local.wireGuardConfigs,
        remote.wireGuardConfigs,
        keyFields: const ['id', 'name'],
      ),
    );

    await _backupService.restoreBackup(merged);
    final uploaded = await _cloudApiClient.uploadCloudBackup(merged.toJson());
    if (uploaded) {
      final jsonStr = jsonEncode(merged.toJson());
      await _settingsRepository.writeSetting(
        AppSettingsKeys.lastCloudBackupAt,
        merged.exportedAt.toIso8601String(),
      );
      await _settingsRepository.writeSetting(
        AppSettingsKeys.lastCloudBackupSize,
        utf8.encode(jsonStr).length.toString(),
      );
    }
    return uploaded;
  }

  static List<Map<String, Object?>> _mergeRecords(
    List<Map<String, Object?>> local,
    List<Map<String, Object?>> remote, {
    List<String> keyFields = const ['id'],
  }) {
    final merged = <String, Map<String, Object?>>{};
    String key(Map<String, Object?> record) {
      for (final field in keyFields) {
        final value = record[field]?.toString().trim();
        if (value != null && value.isNotEmpty) return '$field:$value';
      }
      return 'anonymous:${merged.length}';
    }

    for (final record in local) {
      merged[key(record)] = Map<String, Object?>.from(record);
    }
    // Apply remote last so a cloud edit is consistent across all companions.
    for (final record in remote) {
      merged[key(record)] = Map<String, Object?>.from(record);
    }
    return merged.values.toList(growable: false);
  }

  Future<bool> autoRestoreFromCloudIfLocalEmpty() async {
    final routers = await _database.select(_database.routers).get();
    if (routers.isNotEmpty) {
      return false;
    }
    return restoreFromCloud();
  }

  Future<String?> getLastCloudBackupAt() {
    return _settingsRepository.readSetting(AppSettingsKeys.lastCloudBackupAt);
  }

  Future<int?> getLastCloudBackupSize() async {
    final raw = await _settingsRepository.readSetting(
      AppSettingsKeys.lastCloudBackupSize,
    );
    if (raw == null) return null;
    return int.tryParse(raw);
  }
}
