class VoucherEntity {
  const VoucherEntity({
    required this.id,
    required this.routerId,
    required this.username,
    required this.priceMinor,
    required this.currency,
    required this.generatedAt,
    this.profileId,
    this.password,
    this.validityMinutes,
    this.printedAt,
    this.soldAt,
    this.note,
  });

  final String id;
  final String routerId;
  final String? profileId;
  final String username;
  final String? password;
  final int priceMinor;
  final String currency;
  final int? validityMinutes;
  final DateTime generatedAt;
  final DateTime? printedAt;
  final DateTime? soldAt;
  final String? note;
}
