class HotspotUserInput {
  const HotspotUserInput({
    required this.username,
    required this.password,
    this.profile,
    this.server,
    this.comment,
    this.limitUptime,
    this.limitBytesTotal,
  });

  final String username;
  final String password;
  final String? profile;
  final String? server;
  final String? comment;
  final String? limitUptime;
  final int? limitBytesTotal;

  Map<String, String> toRouterOsAttributes() {
    return {
      'name': username,
      'password': password,
      if (profile != null && profile!.isNotEmpty) 'profile': profile!,
      if (server != null && server!.isNotEmpty) 'server': server!,
      if (comment != null && comment!.isNotEmpty) 'comment': comment!,
      if (limitUptime != null && limitUptime!.isNotEmpty)
        'limit-uptime': limitUptime!,
      if (limitBytesTotal != null) 'limit-bytes-total': '$limitBytesTotal',
    };
  }
}
