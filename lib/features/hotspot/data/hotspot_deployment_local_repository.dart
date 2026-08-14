import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/hotspot_deployment_entity.dart';
import '../domain/repositories/hotspot_deployment_repository.dart';

class HotspotDeploymentLocalRepository implements HotspotDeploymentRepository {
  const HotspotDeploymentLocalRepository(this._database);
  final AppDatabase _database;

  @override
  Future<void> save(HotspotDeploymentEntity deployment) => _database
      .into(_database.hotspotDeploymentHistory)
      .insertOnConflictUpdate(
        HotspotDeploymentHistoryCompanion.insert(
          id: deployment.id,
          routerId: deployment.routerId,
          routerName: deployment.routerName,
          preset: deployment.preset,
          serverName: deployment.serverName,
          profileName: deployment.profileName,
          serverAction: deployment.serverAction,
          profileAction: deployment.profileAction,
          status: deployment.status.name,
          message: Value(deployment.message),
          deployedAt: deployment.deployedAt,
        ),
      );

  @override
  Future<List<HotspotDeploymentEntity>> getHistory({String? routerId}) async {
    final query = _database.select(_database.hotspotDeploymentHistory)
      ..orderBy([(row) => OrderingTerm.desc(row.deployedAt)]);
    if (routerId != null) query.where((row) => row.routerId.equals(routerId));
    return (await query.get())
        .map(
          (row) => HotspotDeploymentEntity(
            id: row.id,
            routerId: row.routerId,
            routerName: row.routerName,
            preset: row.preset,
            serverName: row.serverName,
            profileName: row.profileName,
            serverAction: row.serverAction,
            profileAction: row.profileAction,
            status: HotspotDeploymentStatus.values.byName(row.status),
            message: row.message,
            deployedAt: row.deployedAt,
          ),
        )
        .toList();
  }
}
