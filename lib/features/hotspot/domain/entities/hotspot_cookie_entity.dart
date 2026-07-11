class HotspotCookieEntity {
  const HotspotCookieEntity({
    required this.id,
    required this.user,
    this.macAddress,
    this.expiresIn,
    this.domain,
  });

  final String id;
  final String user;
  final String? macAddress;
  final String? expiresIn;
  final String? domain;

  factory HotspotCookieEntity.fromRouterOs(Map<String, String> record) {
    return HotspotCookieEntity(
      id: record['.id'] ?? '',
      user: record['user'] ?? '',
      macAddress: record['mac-address'],
      expiresIn: record['expires-in'],
      domain: record['domain'],
    );
  }
}
