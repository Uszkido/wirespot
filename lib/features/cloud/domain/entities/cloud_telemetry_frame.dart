class CloudTelemetryFrame {
  const CloudTelemetryFrame({
    required this.routerId,
    required this.cpuLoad,
    required this.freeMemoryMb,
    required this.totalMemoryMb,
    required this.uptimeSeconds,
    required this.activeHotspotUsersCount,
    required this.timestamp,
  });

  final String routerId;
  final double cpuLoad;
  final double freeMemoryMb;
  final double totalMemoryMb;
  final int uptimeSeconds;
  final int activeHotspotUsersCount;
  final DateTime timestamp;

  factory CloudTelemetryFrame.fromJson(Map<String, Object?> json) {
    return CloudTelemetryFrame(
      routerId: json['routerId'] as String? ?? 'unknown',
      cpuLoad: (json['cpuLoad'] as num?)?.toDouble() ?? 0.0,
      freeMemoryMb: (json['freeMemoryMb'] as num?)?.toDouble() ?? 0.0,
      totalMemoryMb: (json['totalMemoryMb'] as num?)?.toDouble() ?? 0.0,
      uptimeSeconds: json['uptimeSeconds'] as int? ?? 0,
      activeHotspotUsersCount: json['activeHotspotUsersCount'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'routerId': routerId,
      'cpuLoad': cpuLoad,
      'freeMemoryMb': freeMemoryMb,
      'totalMemoryMb': totalMemoryMb,
      'uptimeSeconds': uptimeSeconds,
      'activeHotspotUsersCount': activeHotspotUsersCount,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
