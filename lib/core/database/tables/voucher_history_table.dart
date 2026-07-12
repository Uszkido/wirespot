import 'package:drift/drift.dart';

@DataClassName('VoucherRecord')
class VoucherHistory extends Table {
  TextColumn get id => text()();
  TextColumn get routerId => text()();
  TextColumn get profileId => text().nullable()();
  TextColumn get username => text().withLength(min: 1, max: 80)();
  BoolColumn get hasPassword => boolean().withDefault(const Constant(false))();
  IntColumn get priceMinor => integer().withDefault(const Constant(0))();
  TextColumn get currency =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('NGN'))();
  IntColumn get validityMinutes => integer().nullable()();
  DateTimeColumn get generatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get printedAt => dateTime().nullable()();
  DateTimeColumn get soldAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
