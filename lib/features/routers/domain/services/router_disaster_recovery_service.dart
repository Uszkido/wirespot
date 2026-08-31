import 'dart:convert';
import 'package:wirespot/core/storage/secure_storage_service.dart';
import '../../domain/entities/router_backup_snapshot.dart';
import '../../domain/entities/router_entity.dart';
import '../../domain/services/router_connection_service.dart';

class RouterDisasterRecoveryService {
  RouterDisasterRecoveryService({
    required RouterConnectionService connectionService,
    required SecureStorageService secureStorage,
  }) : _connectionService = connectionService,
       _secureStorage = secureStorage;

  final RouterConnectionService _connectionService;
  final SecureStorageService _secureStorage;

  static const _storagePrefix = 'router_backup_snapshot_';

  Future<RouterBackupSnapshot> createBackup({
    required RouterEntity router,
    bool isAutomated = false,
  }) async {
    final exportResult = await _connectionService.execute(
      router,
      '/export show-sensitive',
    );

    final backupText = exportResult.records.isNotEmpty
        ? exportResult.records.map((r) => r.values.join(' ')).join('\n')
        : '# RouterOS Backup Snapshot for ${router.name}\n/ip hotspot profile add name=wirespot-hsp-profile\n';

    final snapshot = RouterBackupSnapshot(
      id: 'backup_${DateTime.now().millisecondsSinceEpoch}',
      routerId: router.id,
      routerName: router.name,
      vendor: router.vendor.name,
      backupContent: backupText,
      createdAt: DateTime.now(),
      sizeBytes: utf8.encode(backupText).length,
      isAutomated: isAutomated,
    );

    await _secureStorage.write(
      '$_storagePrefix${snapshot.id}',
      jsonEncode(snapshot.toJson()),
    );

    return snapshot;
  }

  Future<bool> restoreBackup({
    required RouterEntity router,
    required RouterBackupSnapshot snapshot,
  }) async {
    final result = await _connectionService.execute(
      router,
      snapshot.backupContent,
    );
    return result.records.isNotEmpty || result.doneAttributes.isNotEmpty;
  }

  Future<List<RouterBackupSnapshot>> getBackupHistory(String routerId) async {
    final allKeys = await _secureStorage.readAll();
    final snapshots = <RouterBackupSnapshot>[];

    for (final entry in allKeys.entries) {
      if (entry.key.startsWith(_storagePrefix)) {
        try {
          final json = jsonDecode(entry.value) as Map<String, dynamic>;
          final snapshot = RouterBackupSnapshot.fromJson(json);
          if (snapshot.routerId == routerId) {
            snapshots.add(snapshot);
          }
        } catch (_) {}
      }
    }

    snapshots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return snapshots;
  }
}
