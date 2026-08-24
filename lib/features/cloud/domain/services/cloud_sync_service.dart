import 'package:uuid/uuid.dart';

import '../../data/cloud_api_client.dart';
import '../entities/cloud_sync_operation.dart';
import '../repositories/cloud_sync_repository.dart';

class CloudSyncService {
  CloudSyncService({
    required CloudSyncRepository repository,
    required CloudApiClient apiClient,
    Uuid uuid = const Uuid(),
  }) : _repository = repository,
       _apiClient = apiClient,
       _uuid = uuid;

  final CloudSyncRepository _repository;
  final CloudApiClient _apiClient;
  final Uuid _uuid;

  Future<void> queueUpsert({
    required String resourceType,
    required String resourceId,
    required Map<String, Object?> payload,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    await _repository.enqueue(
      CloudSyncOperation(
        id: id,
        resourceType: resourceType,
        resourceId: resourceId,
        operation: 'upsert',
        payload: payload,
        idempotencyKey: id,
        status: CloudSyncStatus.pending,
        attemptCount: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<int> syncPending() async {
    var synchronized = 0;
    for (final operation in await _repository.pendingOperations()) {
      await _repository.markSyncing(operation.id);
      try {
        await _apiClient.postJson(
          'sync/${operation.resourceType}/${operation.resourceId}',
          data: {
            'operation': operation.operation,
            'payload': operation.payload,
          },
          idempotencyKey: operation.idempotencyKey,
        );
        await _repository.markCompleted(operation.id);
        synchronized += 1;
      } on Object catch (error) {
        await _repository.markFailed(operation.id, error.toString());
      }
    }
    return synchronized;
  }
}
