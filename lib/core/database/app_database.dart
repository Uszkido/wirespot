import 'package:drift/drift.dart';

import 'database_connection.dart';
import 'tables/app_settings_table.dart';
import 'tables/cloud_sync_operations_table.dart';
import 'tables/hotspot_profiles_table.dart';
import 'tables/hotspot_deployment_history_table.dart';
import 'tables/printer_configs_table.dart';
import 'tables/router_groups_table.dart';
import 'tables/routers_table.dart';
import 'tables/sales_table.dart';
import 'tables/voucher_history_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Routers,
    CloudSyncOperations,
    RouterGroups,
    HotspotProfiles,
    HotspotDeploymentHistory,
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
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(routers, routers.requireVpn);
      }
      if (from < 3) {
        await migrator.addColumn(routers, routers.remoteAccessMode);
      }
      if (from < 4) {
        await migrator.addColumn(routers, routers.vendor);
      }
      if (from < 5) {
        await migrator.createTable(hotspotDeploymentHistory);
      }
      if (from < 6) {
        await migrator.createTable(cloudSyncOperations);
      }
    },
  );
}
