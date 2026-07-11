class HotspotQueueEntity {
  const HotspotQueueEntity({
    required this.id,
    required this.name,
    this.target,
    this.maxLimit,
    this.bytes,
    this.disabled = false,
  });

  final String id;
  final String name;
  final String? target;
  final String? maxLimit;
  final String? bytes;
  final bool disabled;

  factory HotspotQueueEntity.fromRouterOs(Map<String, String> record) {
    return HotspotQueueEntity(
      id: record['.id'] ?? '',
      name: record['name'] ?? '',
      target: record['target'],
      maxLimit: record['max-limit'],
      bytes: record['bytes'],
      disabled: record['disabled'] == 'true',
    );
  }
}
