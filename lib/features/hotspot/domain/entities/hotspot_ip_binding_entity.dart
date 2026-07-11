class HotspotIpBindingEntity {
  const HotspotIpBindingEntity({
    required this.id,
    this.address,
    this.macAddress,
    this.server,
    this.type,
    this.comment,
    this.disabled = false,
  });

  final String id;
  final String? address;
  final String? macAddress;
  final String? server;
  final String? type;
  final String? comment;
  final bool disabled;

  factory HotspotIpBindingEntity.fromRouterOs(Map<String, String> record) {
    return HotspotIpBindingEntity(
      id: record['.id'] ?? '',
      address: record['address'],
      macAddress: record['mac-address'],
      server: record['server'],
      type: record['type'],
      comment: record['comment'],
      disabled: record['disabled'] == 'true',
    );
  }
}
