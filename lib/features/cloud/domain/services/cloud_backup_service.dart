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
  })  : _cloudApiClient = cloudApiClient,
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
