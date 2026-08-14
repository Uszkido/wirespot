import 'package:drift/drift.dart';

@DataClassName('HotspotDeploymentRecord')
class HotspotDeploymentHistory extends Table {
  TextColumn get id => text()();
  TextColumn get routerId => text()();
  TextColumn get routerName => text()();
  TextColumn get preset => text()();
  TextColumn get serverName => text()();
  TextColumn get profileName => text()();
  TextColumn get serverAction => text()();
  TextColumn get profileAction => text()();
  TextColumn get status => text()();
  TextColumn get message => text().nullable()();
  DateTimeColumn get deployedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
