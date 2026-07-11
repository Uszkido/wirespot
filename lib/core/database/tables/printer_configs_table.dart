import 'package:drift/drift.dart';

@DataClassName('PrinterConfigRecord')
class PrinterConfigs extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get address => text().withLength(min: 1, max: 120)();
  IntColumn get paperWidthMm => integer().withDefault(const Constant(58))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
