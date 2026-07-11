class HotspotUserEntity {
  const HotspotUserEntity({
    required this.id,
    required this.name,
    this.profile,
    this.server,
    this.comment,
    this.disabled = false,
    this.uptime,
    this.bytesIn,
    this.bytesOut,
    this.limitUptime,
    this.limitBytesTotal,
  });

  final String id;
  final String name;
  final String? profile;
  final String? server;
  final String? comment;
  final bool disabled;
  final String? uptime;
  final int? bytesIn;
  final int? bytesOut;
  final String? limitUptime;
  final int? limitBytesTotal;

  factory HotspotUserEntity.fromRouterOs(Map<String, String> record) {
    return HotspotUserEntity(
      id: record['.id'] ?? '',
      name: record['name'] ?? '',
      profile: record['profile'],
      server: record['server'],
      comment: record['comment'],
      disabled: record['disabled'] == 'true',
      uptime: record['uptime'],
      bytesIn: int.tryParse(record['bytes-in'] ?? ''),
      bytesOut: int.tryParse(record['bytes-out'] ?? ''),
      limitUptime: record['limit-uptime'],
      limitBytesTotal: int.tryParse(record['limit-bytes-total'] ?? ''),
    );
  }
}
