class RouterBackupSnapshot {
  const RouterBackupSnapshot({
    required this.id,
    required this.routerId,
    required this.routerName,
    required this.vendor,
    required this.backupContent,
    required this.createdAt,
    this.sizeBytes = 0,
    this.isAutomated = false,
  });

  final String id;
  final String routerId;
  final String routerName;
  final String vendor;
  final String backupContent;
  final DateTime createdAt;
  final int sizeBytes;
  final bool isAutomated;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routerId': routerId,
      'routerName': routerName,
      'vendor': vendor,
      'backupContent': backupContent,
      'createdAt': createdAt.toIso8601String(),
      'sizeBytes': sizeBytes,
      'isAutomated': isAutomated,
    };
  }

  factory RouterBackupSnapshot.fromJson(Map<String, dynamic> json) {
    return RouterBackupSnapshot(
      id: json['id'] as String? ?? 'backup_0',
      routerId: json['routerId'] as String? ?? 'router_0',
      routerName: json['routerName'] as String? ?? 'Router',
      vendor: json['vendor'] as String? ?? 'mikrotik',
      backupContent: json['backupContent'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      isAutomated: json['isAutomated'] as bool? ?? false,
    );
  }
}
