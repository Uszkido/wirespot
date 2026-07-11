import 'package:drift/drift.dart';

@DataClassName('RouterRecord')
class Routers extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().nullable()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get host => text().withLength(min: 1, max: 255)();
  IntColumn get apiPort => integer().withDefault(const Constant(8728))();
  BoolColumn get useSsl => boolean().withDefault(const Constant(false))();
  TextColumn get username => text().withLength(min: 1, max: 80)();
  TextColumn get identity => text().nullable()();
  TextColumn get version => text().nullable()();
  TextColumn get boardName => text().nullable()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastConnectedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
