import '../entities/app_settings.dart';
import '../entities/backup_payload.dart';
import '../repositories/settings_repository.dart';

class BackupService {
  const BackupService(this._repository);

  final SettingsRepository _repository;

  Future<BackupPayload> buildBackup() async {
    final printers = await _repository.getPrinters();
    final settings = <String, String>{};
    for (final key in [
      AppSettingsKeys.themeMode,
      AppSettingsKeys.languageCode,
      AppSettingsKeys.notificationsEnabled,
      AppSettingsKeys.businessName,
    ]) {
      final value = await _repository.readSetting(key);
      if (value != null) {
        settings[key] = value;
      }
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
    );
  }
}
