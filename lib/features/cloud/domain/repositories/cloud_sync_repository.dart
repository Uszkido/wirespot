import '../entities/cloud_sync_operation.dart';

abstract interface class CloudSyncRepository {
  Future<void> enqueue(CloudSyncOperation operation);
  Future<List<CloudSyncOperation>> pendingOperations();
  Future<void> markSyncing(String id);
  Future<void> markCompleted(String id);
  Future<void> markFailed(String id, String error);
  Future<int> clearCompleted();
  Future<int> retryFailed();
}
