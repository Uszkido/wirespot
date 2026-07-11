class HotspotActiveSessionEntity {
  const HotspotActiveSessionEntity({
    required this.id,
    required this.user,
    this.address,
    this.macAddress,
    this.uptime,
    this.sessionTimeLeft,
    this.bytesIn,
    this.bytesOut,
    this.loginBy,
    this.server,
  });

  final String id;
  final String user;
  final String? address;
  final String? macAddress;
  final String? uptime;
  final String? sessionTimeLeft;
  final int? bytesIn;
  final int? bytesOut;
  final String? loginBy;
  final String? server;

  factory HotspotActiveSessionEntity.fromRouterOs(Map<String, String> record) {
    return HotspotActiveSessionEntity(
      id: record['.id'] ?? '',
      user: record['user'] ?? '',
      address: record['address'],
      macAddress: record['mac-address'],
      uptime: record['uptime'],
      sessionTimeLeft: record['session-time-left'],
      bytesIn: int.tryParse(record['bytes-in'] ?? ''),
      bytesOut: int.tryParse(record['bytes-out'] ?? ''),
      loginBy: record['login-by'],
      server: record['server'],
    );
  }
}
