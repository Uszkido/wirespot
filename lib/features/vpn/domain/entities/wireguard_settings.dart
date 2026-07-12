class WireGuardSettings {
  const WireGuardSettings({
    this.selectedTunnelName = 'wirespot',
    this.autoReconnectEnabled = false,
  });

  final String selectedTunnelName;
  final bool autoReconnectEnabled;

  WireGuardSettings copyWith({
    String? selectedTunnelName,
    bool? autoReconnectEnabled,
  }) {
    return WireGuardSettings(
      selectedTunnelName: selectedTunnelName ?? this.selectedTunnelName,
      autoReconnectEnabled:
          autoReconnectEnabled ?? this.autoReconnectEnabled,
    );
  }
}
