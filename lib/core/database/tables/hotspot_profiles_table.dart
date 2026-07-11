import 'package:drift/drift.dart';

@DataClassName('HotspotProfileRecord')
class HotspotProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get routerId => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get rateLimit => text().nullable()();
  IntColumn get validityMinutes => integer().nullable()();
  IntColumn get priceMinor => integer().withDefault(const Constant(0))();
  TextColumn get currency =>
      text().withLength(min: 3, max: 3).withDefault(const Constant('NGN'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
