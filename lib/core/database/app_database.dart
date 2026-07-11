import 'package:drift/drift.dart';

import 'database_connection.dart';
import 'tables/app_settings_table.dart';
import 'tables/hotspot_profiles_table.dart';
import 'tables/printer_configs_table.dart';
import 'tables/router_groups_table.dart';
import 'tables/routers_table.dart';
import 'tables/sales_table.dart';
import 'tables/voucher_history_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Routers,
    RouterGroups,
    HotspotProfiles,
    VoucherHistory,
    Sales,
    AppSettings,
    PrinterConfigs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAll(),
      );
}
