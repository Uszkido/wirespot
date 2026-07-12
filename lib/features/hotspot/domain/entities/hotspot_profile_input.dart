class HotspotProfileInput {
  const HotspotProfileInput({
    required this.name,
    this.rateLimit,
    this.uploadLimit,
    this.downloadLimit,
    this.sessionTimeout,
    this.idleTimeout,
    this.sharedUsers,
    this.keepaliveTimeout,
    this.priceMinor,
    this.dataLimitBytes,
  });

  final String name;
  final String? rateLimit;
  final String? uploadLimit;
  final String? downloadLimit;
  final String? sessionTimeout;
  final String? idleTimeout;
  final int? sharedUsers;
  final String? keepaliveTimeout;
  final int? priceMinor;
  final int? dataLimitBytes;

  Map<String, String> toRouterOsAttributes() {
    final builtRateLimit = rateLimit?.trim().isNotEmpty == true
        ? rateLimit!.trim()
        : _builtRateLimit();
    return {
      'name': name,
      if (builtRateLimit != null && builtRateLimit.isNotEmpty)
        'rate-limit': builtRateLimit,
      if (sessionTimeout != null && sessionTimeout!.isNotEmpty)
        'session-timeout': sessionTimeout!,
      if (idleTimeout != null && idleTimeout!.isNotEmpty)
        'idle-timeout': idleTimeout!,
      if (sharedUsers != null) 'shared-users': '$sharedUsers',
      if (keepaliveTimeout != null && keepaliveTimeout!.isNotEmpty)
        'keepalive-timeout': keepaliveTimeout!,
    };
  }

  String? _builtRateLimit() {
    final upload = uploadLimit?.trim();
    final download = downloadLimit?.trim();
    if (upload == null ||
        upload.isEmpty ||
        download == null ||
        download.isEmpty) {
      return null;
    }
    return '$upload/$download';
  }
}
