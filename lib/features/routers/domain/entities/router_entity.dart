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
  final String username;
  final String? identity;
  final String? version;
  final String? boardName;
  final bool isEnabled;
  final DateTime? lastConnectedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
