import '../entities/printer_config_entity.dart';

abstract interface class SettingsRepository {
  Future<String?> readSetting(String key);

  Future<void> writeSetting(String key, String value);

  Future<List<PrinterConfigEntity>> getPrinters();

  Future<void> savePrinter(PrinterConfigEntity printer);

  Future<void> deletePrinter(String id);
}
