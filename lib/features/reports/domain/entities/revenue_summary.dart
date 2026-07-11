import 'sale_entity.dart';

class RevenueSummary {
  const RevenueSummary({
    required this.sales,
    required this.totalMinor,
    required this.currency,
    required this.from,
    required this.to,
  });

  final List<SaleEntity> sales;
  final int totalMinor;
  final String currency;
  final DateTime from;
  final DateTime to;

  int get transactionCount => sales.length;

  double get totalMajor => totalMinor / 100;
}
