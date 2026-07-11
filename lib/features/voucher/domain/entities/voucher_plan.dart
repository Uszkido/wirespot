class VoucherPlan {
  const VoucherPlan({
    required this.id,
    required this.name,
    required this.validityMinutes,
    required this.priceMinor,
    this.rateLimit,
    this.currency = 'NGN',
  });

  final String id;
  final String name;
  final int? validityMinutes;
  final int priceMinor;
  final String? rateLimit;
  final String currency;

  static const defaults = [
    VoucherPlan(id: '1h', name: '1 Hour', validityMinutes: 60, priceMinor: 0),
    VoucherPlan(id: '3h', name: '3 Hours', validityMinutes: 180, priceMinor: 0),
    VoucherPlan(id: '6h', name: '6 Hours', validityMinutes: 360, priceMinor: 0),
    VoucherPlan(id: '12h', name: '12 Hours', validityMinutes: 720, priceMinor: 0),
    VoucherPlan(id: '1d', name: '1 Day', validityMinutes: 1440, priceMinor: 0),
    VoucherPlan(id: '3d', name: '3 Days', validityMinutes: 4320, priceMinor: 0),
    VoucherPlan(id: '7d', name: '7 Days', validityMinutes: 10080, priceMinor: 0),
    VoucherPlan(id: '30d', name: '30 Days', validityMinutes: 43200, priceMinor: 0),
    VoucherPlan(id: 'unlimited', name: 'Unlimited', validityMinutes: null, priceMinor: 0),
  ];
}
