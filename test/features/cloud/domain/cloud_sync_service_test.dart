import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/cloud/data/cloud_api_client.dart';
import 'package:wirespot/features/cloud/domain/entities/cloud_sync_operation.dart';
import 'package:wirespot/features/cloud/domain/repositories/cloud_sync_repository.dart';
import 'package:wirespot/features/cloud/domain/services/cloud_sync_service.dart';

class MemoryCloudSyncRepository implements CloudSyncRepository {
  final List<CloudSyncOperation> _items = [];

  @override
  Future<void> enqueue(CloudSyncOperation operation) async {
    _items.add(operation);
  }

  @override
  Future<List<CloudSyncOperation>> pendingOperations() async {
    return _items
        .where(
          (op) =>
              op.status == CloudSyncStatus.pending ||
              op.status == CloudSyncStatus.failed,
        )
        .toList();
  }

  @override
  Future<void> markSyncing(String id) async {
    _updateStatus(id, CloudSyncStatus.syncing);
  }

  @override
  Future<void> markCompleted(String id) async {
    _updateStatus(id, CloudSyncStatus.completed);
  }

  @override
  Future<void> markFailed(String id, String error) async {
    final index = _items.indexWhere((op) => op.id == id);
    if (index != -1) {
      final old = _items[index];
      _items[index] = CloudSyncOperation(
        id: old.id,
        resourceType: old.resourceType,
        resourceId: old.resourceId,
        operation: old.operation,
        payload: old.payload,
        idempotencyKey: old.idempotencyKey,
        status: CloudSyncStatus.failed,
        attemptCount: old.attemptCount + 1,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        lastError: error,
      );
    }
  }

  @override
  Future<int> clearCompleted() async {
    final initialCount = _items.length;
    _items.removeWhere((op) => op.status == CloudSyncStatus.completed);
    return initialCount - _items.length;
  }

  @override
  Future<int> retryFailed() async {
    int count = 0;
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].status == CloudSyncStatus.failed) {
        final old = _items[i];
        _items[i] = CloudSyncOperation(
          id: old.id,
          resourceType: old.resourceType,
          resourceId: old.resourceId,
          operation: old.operation,
          payload: old.payload,
          idempotencyKey: old.idempotencyKey,
          status: CloudSyncStatus.pending,
          attemptCount: old.attemptCount,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
          lastError: null,
        );
        count++;
      }
    }
    return count;
  }

  void _updateStatus(String id, CloudSyncStatus status) {
    final index = _items.indexWhere((op) => op.id == id);
    if (index != -1) {
      final old = _items[index];
      _items[index] = CloudSyncOperation(
        id: old.id,
        resourceType: old.resourceType,
        resourceId: old.resourceId,
        operation: old.operation,
        payload: old.payload,
        idempotencyKey: old.idempotencyKey,
        status: status,
        attemptCount: old.attemptCount,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        lastError: old.lastError,
      );
    }
  }
}

class FakeCloudApiClient implements CloudApiClient {
  final List<Map<String, dynamic>> postedData = [];

  @override
  Future<List<Map<String, dynamic>>> fetchPendingCommands() async => [];

  @override
  Future<bool> acknowledgeCommand({
    required String commandId,
    required String status,
    Map<String, Object?>? resultPayload,
    String? errorMessage,
  }) async => true;

  @override
  Future<bool> postTelemetry(Map<String, Object?> telemetryData) async => true;

  @override
  Future<bool> testConnection() async => true;

  @override
  Future<Response<Map<String, dynamic>>> getJson(String path) {
    throw UnimplementedError();
  }

  @override
  Future<Response<Map<String, dynamic>>> postJson(
    String path, {
    Map<String, Object?> data = const {},
    String? idempotencyKey,
  }) async {
    postedData.add({'path': path, 'data': data, 'key': idempotencyKey});
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {'success': true},
    );
  }
}

void main() {
  test('CloudSyncService queues upsert operation correctly', () async {
    final repository = MemoryCloudSyncRepository();
    final apiClient = FakeCloudApiClient();
    final service = CloudSyncService(
      repository: repository,
      apiClient: apiClient,
    );

    await service.queueUpsert(
      resourceType: 'voucher',
      resourceId: 'v-101',
      payload: {'username': 'user101', 'price': 500},
    );

    final pending = await repository.pendingOperations();
    expect(pending.length, equals(1));
    expect(pending.first.resourceType, equals('voucher'));
    expect(pending.first.resourceId, equals('v-101'));
    expect(pending.first.operation, equals('upsert'));
  });

  test('CloudSyncService syncPending syncs pending operations via API client', () async {
    final repository = MemoryCloudSyncRepository();
    final apiClient = FakeCloudApiClient();
    final service = CloudSyncService(
      repository: repository,
      apiClient: apiClient,
    );

    await service.queueUpsert(
      resourceType: 'voucher',
      resourceId: 'v-102',
      payload: {'username': 'user102'},
    );

    final syncedCount = await service.syncPending();
    expect(syncedCount, equals(1));
    expect(apiClient.postedData.length, equals(1));
    expect(apiClient.postedData.first['path'], equals('sync/voucher/v-102'));

    final pendingAfter = await repository.pendingOperations();
    expect(pendingAfter.isEmpty, isTrue);
  });
}
