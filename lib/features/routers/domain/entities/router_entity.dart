enum RouterRemoteAccessMode {
  localLan(
    label: 'Local LAN',
    description: 'Direct on-site access from the same trusted network.',
    requiresPrivateTunnel: false,
    recommendedPort: 8728,
    recommendedSsl: false,
  ),
  wireGuard(
    label: 'WireGuard',
    description: 'Private VPN access using a WireGuard tunnel.',
    requiresPrivateTunnel: true,
    recommendedPort: 8728,
    recommendedSsl: false,
  ),
  backToHome(
    label: 'MikroTik Back To Home',
    description: 'MikroTik assisted WireGuard access for routers behind NAT.',
    requiresPrivateTunnel: true,
    recommendedPort: 8728,
    recommendedSsl: false,
  ),
  zeroTier(
    label: 'ZeroTier',
    description: 'Private overlay network access through ZeroTier.',
    requiresPrivateTunnel: true,
    recommendedPort: 8728,
    recommendedSsl: false,
  ),
  publicApiSsl(
    label: 'Public API-SSL',
    description:
        'Advanced public endpoint using RouterOS API-SSL and firewall limits.',
    requiresPrivateTunnel: false,
    recommendedPort: 8729,
    recommendedSsl: true,
  ),
  custom(
    label: 'Custom / Advanced',
    description: 'Operator-managed path with custom firewall and routing.',
    requiresPrivateTunnel: false,
    recommendedPort: 8728,
    recommendedSsl: false,
  );

  const RouterRemoteAccessMode({
    required this.label,
    required this.description,
    required this.requiresPrivateTunnel,
    required this.recommendedPort,
    required this.recommendedSsl,
  });

  final String label;
  final String description;
  final bool requiresPrivateTunnel;
  final int recommendedPort;
  final bool recommendedSsl;

  static RouterRemoteAccessMode fromName(String? name, {bool? requireVpn}) {
    final mode = RouterRemoteAccessMode.values.firstWhere(
      (value) => value.name == name,
      orElse: () => requireVpn == false
          ? RouterRemoteAccessMode.localLan
          : RouterRemoteAccessMode.wireGuard,
    );
    return mode;
  }
}

class RouterEntity {
  const RouterEntity({
    required this.id,
    required this.name,
    required this.host,
    required this.username,
    this.groupId,
    this.apiPort = 8728,
    this.useSsl = false,
    this.requireVpn = true,
    this.remoteAccessMode = RouterRemoteAccessMode.wireGuard,
    this.identity,
    this.version,
    this.boardName,
    this.isEnabled = true,
    this.lastConnectedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? groupId;
  final String name;
  final String host;
  final int apiPort;
  final bool useSsl;
  final bool requireVpn;
  final RouterRemoteAccessMode remoteAccessMode;
  final String username;
  final String? identity;
  final String? version;
  final String? boardName;
  final bool isEnabled;
  final DateTime? lastConnectedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get requiresPrivateTunnel =>
      requireVpn || remoteAccessMode.requiresPrivateTunnel;
}
