class SaleEntity {
  const SaleEntity({
    required this.id,
    required this.routerId,
    required this.amountMinor,
    required this.currency,
    required this.soldAt,
    this.voucherId,
    this.paymentMethod,
    this.note,
  });

  final String id;
  final String? voucherId;
  final String routerId;
  final int amountMinor;
  final String currency;
  final String? paymentMethod;
  final DateTime soldAt;
  final String? note;
}
