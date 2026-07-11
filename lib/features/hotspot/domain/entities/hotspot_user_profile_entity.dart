class HotspotUserProfileEntity {
  const HotspotUserProfileEntity({
    required this.id,
    required this.name,
    this.rateLimit,
    this.sessionTimeout,
    this.sharedUsers,
    this.keepaliveTimeout,
    this.statusAutorefresh,
    this.addMacCookie,
  });

  final String id;
  final String name;
  final String? rateLimit;
  final String? sessionTimeout;
  final int? sharedUsers;
  final String? keepaliveTimeout;
  final String? statusAutorefresh;
  final bool? addMacCookie;

  factory HotspotUserProfileEntity.fromRouterOs(Map<String, String> record) {
    return HotspotUserProfileEntity(
      id: record['.id'] ?? '',
      name: record['name'] ?? '',
      rateLimit: record['rate-limit'],
      sessionTimeout: record['session-timeout'],
      sharedUsers: int.tryParse(record['shared-users'] ?? ''),
      keepaliveTimeout: record['keepalive-timeout'],
      statusAutorefresh: record['status-autorefresh'],
      addMacCookie: switch (record['add-mac-cookie']) {
        'true' => true,
        'false' => false,
        _ => null,
      },
    );
  }
}
