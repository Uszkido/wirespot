import 'package:drift/drift.dart';

@DataClassName('CloudSyncOperationRecord')
class CloudSyncOperations extends Table {
  TextColumn get id => text()();
  TextColumn get resourceType => text()();
  TextColumn get resourceId => text()();
  TextColumn get operation => text()();
  TextColumn get payloadJson => text()();
  TextColumn get idempotencyKey => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
