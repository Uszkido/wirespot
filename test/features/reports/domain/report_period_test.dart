import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/reports/domain/entities/report_period.dart';

void main() {
  test('daily range starts at beginning of day', () {
    final range = ReportDateRange.forPeriod(
      ReportPeriod.daily,
      now: DateTime(2026, 7, 10, 14, 30),
    );

    expect(range.from, DateTime(2026, 7, 10));
    expect(range.to, DateTime(2026, 7, 10, 14, 30));
  });

  test('monthly range starts at beginning of month', () {
    final range = ReportDateRange.forPeriod(
      ReportPeriod.monthly,
      now: DateTime(2026, 7, 10, 14, 30),
    );

    expect(range.from, DateTime(2026, 7));
  });
}
