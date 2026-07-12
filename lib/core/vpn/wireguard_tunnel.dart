class WireGuardTunnel {
  const WireGuardTunnel({
    required this.name,
    required this.config,
    this.createdAt,
  });

  final String name;
  final String config;
  final DateTime? createdAt;

  Map<String, Object?> toPlatformMap() {
    return {'name': name, 'config': config};
  }
}
