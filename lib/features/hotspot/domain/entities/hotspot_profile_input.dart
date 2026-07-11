class HotspotProfileInput {
  const HotspotProfileInput({
    required this.name,
    this.rateLimit,
    this.sessionTimeout,
    this.sharedUsers,
    this.keepaliveTimeout,
  });

  final String name;
  final String? rateLimit;
  final String? sessionTimeout;
  final int? sharedUsers;
  final String? keepaliveTimeout;

  Map<String, String> toRouterOsAttributes() {
    return {
      'name': name,
      if (rateLimit != null && rateLimit!.isNotEmpty)
        'rate-limit': rateLimit!,
      if (sessionTimeout != null && sessionTimeout!.isNotEmpty)
        'session-timeout': sessionTimeout!,
      if (sharedUsers != null) 'shared-users': '$sharedUsers',
      if (keepaliveTimeout != null && keepaliveTimeout!.isNotEmpty)
        'keepalive-timeout': keepaliveTimeout!,
    };
  }
}
