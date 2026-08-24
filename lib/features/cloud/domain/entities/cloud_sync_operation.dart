enum CloudSyncStatus { pending, syncing, failed, completed }

class CloudSyncOperation {
  const CloudSyncOperation({
    required this.id,
    required this.resourceType,
    required this.resourceId,
    required this.operation,
    required this.payload,
    required this.idempotencyKey,
    required this.status,
    required this.attemptCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastError,
  });

  final String id;
  final String resourceType;
  final String resourceId;
  final String operation;
  final Map<String, Object?> payload;
  final String idempotencyKey;
  final CloudSyncStatus status;
  final int attemptCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
}
