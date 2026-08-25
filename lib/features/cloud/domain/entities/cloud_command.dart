class CloudCommand {
  const CloudCommand({
    required this.id,
    required this.type,
    this.targetResourceId,
    this.params = const {},
    this.status = 'pending',
    required this.createdAt,
    this.executedAt,
    this.resultPayload,
    this.errorMessage,
  });

  final String id;
  final String type;
  final String? targetResourceId;
  final Map<String, Object?> params;
  final String status;
  final DateTime createdAt;
  final DateTime? executedAt;
  final Map<String, Object?>? resultPayload;
  final String? errorMessage;

  factory CloudCommand.fromJson(Map<String, Object?> json) {
    return CloudCommand(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'unknown',
      targetResourceId: json['targetResourceId'] as String?,
      params:
          (json['params'] as Map<String, dynamic>?)?.cast<String, Object?>() ??
          const {},
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      executedAt: json['executedAt'] != null
          ? DateTime.parse(json['executedAt'] as String)
          : null,
      resultPayload: (json['resultPayload'] as Map<String, dynamic>?)
          ?.cast<String, Object?>(),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type,
      if (targetResourceId != null) 'targetResourceId': targetResourceId,
      'params': params,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (executedAt != null) 'executedAt': executedAt!.toIso8601String(),
      if (resultPayload != null) 'resultPayload': resultPayload,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  CloudCommand copyWith({
    String? status,
    DateTime? executedAt,
    Map<String, Object?>? resultPayload,
    String? errorMessage,
  }) {
    return CloudCommand(
      id: id,
      type: type,
      targetResourceId: targetResourceId,
      params: params,
      status: status ?? this.status,
      createdAt: createdAt,
      executedAt: executedAt ?? this.executedAt,
      resultPayload: resultPayload ?? this.resultPayload,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
