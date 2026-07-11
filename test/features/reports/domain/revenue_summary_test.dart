import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/reports/domain/entities/revenue_summary.dart';

void main() {
  test('converts minor currency units to major units', () {
    final summary = RevenueSummary(
      sales: const [],
      totalMinor: 12345,
      currency: 'NGN',
      from: DateTime(2026),
      to: DateTime(2026, 1, 2),
    );

    expect(summary.totalMajor, 123.45);
    expect(summary.transactionCount, 0);
  });
}
