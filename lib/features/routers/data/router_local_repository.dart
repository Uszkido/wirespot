import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/storage/router_credential_store.dart';
import '../../../core/storage/router_credentials.dart';
import '../domain/entities/router_entity.dart';
import '../domain/entities/router_group_entity.dart';
import '../domain/repositories/router_repository.dart';
import '../../cloud/domain/services/cloud_backup_service.dart';
import '../../cloud/domain/services/cloud_workspace_sync_service.dart';

class RouterLocalRepository implements RouterRepository {
  const RouterLocalRepository(
    this._database,
    this._credentialStore, {
    CloudWorkspaceSyncService? cloudWorkspaceSyncService,
    CloudBackupService? cloudBackupService,
  }) : _cloudWorkspaceSyncService = cloudWorkspaceSyncService,
       _cloudBackupService = cloudBackupService;

  final AppDatabase _database;
  final RouterCredentialStore _credentialStore;
  final CloudWorkspaceSyncService? _cloudWorkspaceSyncService;
  final CloudBackupService? _cloudBackupService;

  @override
  Stream<List<RouterEntity>> watchRouters() {
    return (_database.select(_database.routers)
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .watch()
        .map((records) => records.map(_mapRouter).toList());
  }

  @override
  Future<List<RouterEntity>> getRouters() async {
    final records = await (_database.select(
      _database.routers,
    )..orderBy([(table) => OrderingTerm.asc(table.name)])).get();
    return records.map(_mapRouter).toList();
  }

  @override
  Future<RouterEntity?> getRouter(String id) async {
    final record = await (_database.select(
      _database.routers,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return record == null ? null : _mapRouter(record);
  }

  @override
  Future<void> saveRouter(
    RouterEntity router, {
    RouterCredentials? credentials,
  }) async {
    final now = DateTime.now();
    await _database
        .into(_database.routers)
        .insertOnConflictUpdate(
          RoutersCompanion.insert(
            id: router.id,
            vendor: Value(router.vendor.name),
            name: router.name,
            host: router.host,
            username: router.username,
            groupId: Value(router.groupId),
            apiPort: Value(router.apiPort),
            useSsl: Value(router.useSsl),
            requireVpn: Value(router.requireVpn),
            remoteAccessMode: Value(router.remoteAccessMode.name),
            identity: Value(router.identity),
            version: Value(router.version),
            boardName: Value(router.boardName),
            controllerSiteId: Value(router.controllerSiteId),
            controllerDeviceId: Value(router.controllerDeviceId),
            isEnabled: Value(router.isEnabled),
            lastConnectedAt: Value(router.lastConnectedAt),
            createdAt: Value(router.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );

    if (credentials != null) {
      await _credentialStore.write(router.id, credentials);
    }
    try {
      await _cloudWorkspaceSyncService?.saveRouter(
        routerId: router.id,
        routerData: router.toJson(),
      );
      // The web dashboard reads the shared backup snapshot. Publish the
      // complete workspace after a router change so it appears online without
      // requiring the operator to open Cloud Sync and press Sync Now.
      await _cloudBackupService?.uploadCloudBackup();
    } catch (_) {
      // Local persistence must remain available while cloud sync is offline.
    }
  }

  @override
  Future<void> deleteRouter(String id) async {
    await (_database.delete(
      _database.routers,
    )..where((table) => table.id.equals(id))).go();
    await _credentialStore.delete(id);
    try {
      await _cloudBackupService?.uploadCloudBackup();
    } catch (_) {
      // Local deletion must remain available while cloud sync is offline.
    }
  }

  @override
  Future<void> saveGroup(RouterGroupEntity group) {
    final now = DateTime.now();
    return _database
        .into(_database.routerGroups)
        .insertOnConflictUpdate(
          RouterGroupsCompanion.insert(
            id: group.id,
            name: group.name,
            createdAt: Value(group.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
  }

  @override
  Future<List<RouterGroupEntity>> getGroups() async {
    final records = await (_database.select(
      _database.routerGroups,
    )..orderBy([(table) => OrderingTerm.asc(table.name)])).get();
    return records.map(_mapGroup).toList();
  }
}

RouterEntity _mapRouter(RouterRecord record) {
  return RouterEntity(
    id: record.id,
    groupId: record.groupId,
    vendor: RouterVendor.fromName(record.vendor),
    name: record.name,
    host: record.host,
    apiPort: record.apiPort,
    useSsl: record.useSsl,
    requireVpn: record.requireVpn,
    remoteAccessMode: RouterRemoteAccessMode.fromName(
      record.remoteAccessMode,
      requireVpn: record.requireVpn,
    ),
    username: record.username,
    identity: record.identity,
    version: record.version,
    boardName: record.boardName,
    controllerSiteId: record.controllerSiteId,
    controllerDeviceId: record.controllerDeviceId,
    isEnabled: record.isEnabled,
    lastConnectedAt: record.lastConnectedAt,
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
  );
}

RouterGroupEntity _mapGroup(RouterGroupRecord record) {
  return RouterGroupEntity(
    id: record.id,
    name: record.name,
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
  );
}
