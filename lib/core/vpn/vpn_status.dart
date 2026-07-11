enum VpnConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class VpnStatus {
  const VpnStatus({
    required this.state,
    this.tunnelName,
    this.message,
    this.lastHandshakeAt,
  });

  final VpnConnectionState state;
  final String? tunnelName;
  final String? message;
  final DateTime? lastHandshakeAt;

  bool get isConnected => state == VpnConnectionState.connected;

  factory VpnStatus.fromJson(Map<Object?, Object?> json) {
    final handshakeMillis = json['lastHandshakeAtMillis'];
    return VpnStatus(
      state: _stateFromPlatform(json['state'] as String?),
      tunnelName: json['tunnelName'] as String?,
      message: json['message'] as String?,
      lastHandshakeAt: handshakeMillis is int
          ? DateTime.fromMillisecondsSinceEpoch(handshakeMillis)
          : null,
    );
  }

  static VpnConnectionState _stateFromPlatform(String? value) {
    return switch (value) {
      'connecting' => VpnConnectionState.connecting,
      'connected' => VpnConnectionState.connected,
      'disconnecting' => VpnConnectionState.disconnecting,
      'error' => VpnConnectionState.error,
      _ => VpnConnectionState.disconnected,
    };
  }
}
