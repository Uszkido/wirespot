import '../entities/app_settings.dart';
import '../entities/backup_payload.dart';
import '../entities/printer_config_entity.dart';
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
      AppSettingsKeys.currencyCode,
      AppSettingsKeys.notificationsEnabled,
      AppSettingsKeys.businessName,
      AppSettingsKeys.businessEmail,
      AppSettingsKeys.businessPhone,
      AppSettingsKeys.businessWebsite,
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
