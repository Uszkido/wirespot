import 'package:drift/drift.dart';

@DataClassName('SaleRecord')
class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get voucherId => text().nullable()();
  TextColumn get routerId => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('NGN'))();
  TextColumn get paymentMethod => text().nullable()();
  DateTimeColumn get soldAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
