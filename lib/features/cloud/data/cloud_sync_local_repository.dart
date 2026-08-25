import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/cloud_sync_operation.dart';
import '../domain/repositories/cloud_sync_repository.dart';

class CloudSyncLocalRepository implements CloudSyncRepository {
  const CloudSyncLocalRepository(this._database);
  final AppDatabase _database;

  @override
  Future<void> enqueue(CloudSyncOperation operation) => _database
      .into(_database.cloudSyncOperations)
      .insertOnConflictUpdate(
        CloudSyncOperationsCompanion.insert(
          id: operation.id,
          resourceType: operation.resourceType,
          resourceId: operation.resourceId,
          operation: operation.operation,
          payloadJson: jsonEncode(operation.payload),
          idempotencyKey: operation.idempotencyKey,
          status: Value(operation.status.name),
          attemptCount: Value(operation.attemptCount),
          lastError: Value(operation.lastError),
          createdAt: Value(operation.createdAt),
          updatedAt: Value(operation.updatedAt),
        ),
      );

  @override
  Future<List<CloudSyncOperation>> pendingOperations() async {
    final rows =
        await (_database.select(_database.cloudSyncOperations)
              ..where(
                (row) => row.status.isIn([
                  CloudSyncStatus.pending.name,
                  CloudSyncStatus.failed.name,
                ]),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
            .get();
    return rows.map(_map).toList();
  }

  @override
  Future<void> markSyncing(String id) => _update(id, CloudSyncStatus.syncing);

  @override
  Future<void> markCompleted(String id) =>
      _update(id, CloudSyncStatus.completed);

  @override
  Future<void> markFailed(String id, String error) => _update(
    id,
    CloudSyncStatus.failed,
    error: error,
    incrementAttempts: true,
  );

  @override
  Future<int> clearCompleted() async {
    return (_database.delete(
      _database.cloudSyncOperations,
    )..where((row) => row.status.equals(CloudSyncStatus.completed.name))).go();
  }

  @override
  Future<int> retryFailed() async {
    return (_database.update(
      _database.cloudSyncOperations,
    )..where((row) => row.status.equals(CloudSyncStatus.failed.name))).write(
      CloudSyncOperationsCompanion(
        status: Value(CloudSyncStatus.pending.name),
        lastError: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> _update(
    String id,
    CloudSyncStatus status, {
    String? error,
    bool incrementAttempts = false,
  }) async {
    final row = await (_database.select(
      _database.cloudSyncOperations,
    )..where((entry) => entry.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await (_database.update(
      _database.cloudSyncOperations,
    )..where((entry) => entry.id.equals(id))).write(
      CloudSyncOperationsCompanion(
        status: Value(status.name),
        lastError: Value(error),
        attemptCount: Value(
          incrementAttempts ? row.attemptCount + 1 : row.attemptCount,
        ),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  CloudSyncOperation _map(CloudSyncOperationRecord row) => CloudSyncOperation(
    id: row.id,
    resourceType: row.resourceType,
    resourceId: row.resourceId,
    operation: row.operation,
    payload: (jsonDecode(row.payloadJson) as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, value),
    ),
    idempotencyKey: row.idempotencyKey,
    status: CloudSyncStatus.values.byName(row.status),
    attemptCount: row.attemptCount,
    lastError: row.lastError,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
