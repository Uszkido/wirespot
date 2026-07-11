class HotspotProfileEntity {
  const HotspotProfileEntity({
    required this.id,
    required this.routerId,
    required this.name,
    required this.priceMinor,
    required this.currency,
    this.rateLimit,
    this.validityMinutes,
  });

  final String id;
  final String routerId;
  final String name;
  final String? rateLimit;
  final int? validityMinutes;
  final int priceMinor;
  final String currency;
}
