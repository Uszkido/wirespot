class VpnStatistics {
  const VpnStatistics({
    required this.rxBytes,
    required this.txBytes,
    this.latestHandshakeAt,
  });

  final int rxBytes;
  final int txBytes;
  final DateTime? latestHandshakeAt;

  factory VpnStatistics.fromJson(Map<Object?, Object?> json) {
    final handshakeMillis = json['latestHandshakeAtMillis'];
    return VpnStatistics(
      rxBytes: json['rxBytes'] as int? ?? 0,
      txBytes: json['txBytes'] as int? ?? 0,
      latestHandshakeAt: handshakeMillis is int
          ? DateTime.fromMillisecondsSinceEpoch(handshakeMillis)
          : null,
    );
  }
}
