import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/printer_config_entity.dart';
import '../domain/repositories/settings_repository.dart';

class SettingsLocalRepository implements SettingsRepository {
  const SettingsLocalRepository(this._database);

  final AppDatabase _database;

  @override
  Future<String?> readSetting(String key) async {
    final record = await (_database.select(_database.appSettings)
          ..where((table) => table.key.equals(key)))
        .getSingleOrNull();
    return record?.value;
  }

  @override
  Future<void> writeSetting(String key, String value) {
    return _database.into(_database.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<List<PrinterConfigEntity>> getPrinters() async {
    final records = await (_database.select(_database.printerConfigs)
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .get();
    return records.map(_mapPrinter).toList();
  }

  @override
  Future<void> savePrinter(PrinterConfigEntity printer) {
    final now = DateTime.now();
    return _database.transaction(() async {
      if (printer.isDefault) {
        await _database.update(_database.printerConfigs).write(
              const PrinterConfigsCompanion(isDefault: Value(false)),
            );
      }
      await _database.into(_database.printerConfigs).insertOnConflictUpdate(
            PrinterConfigsCompanion.insert(
              id: printer.id,
              name: printer.name,
              address: printer.address,
              paperWidthMm: Value(printer.paperWidthMm),
              isDefault: Value(printer.isDefault),
              updatedAt: Value(now),
            ),
          );
    });
  }

  @override
  Future<void> deletePrinter(String id) {
    return (_database.delete(_database.printerConfigs)
          ..where((table) => table.id.equals(id)))
        .go();
  }
}

PrinterConfigEntity _mapPrinter(PrinterConfigRecord record) {
  return PrinterConfigEntity(
    id: record.id,
    name: record.name,
    address: record.address,
    paperWidthMm: record.paperWidthMm,
    isDefault: record.isDefault,
  );
}
