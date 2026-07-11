import '../entities/report_period.dart';
import '../entities/revenue_summary.dart';
import '../repositories/report_repository.dart';

class ReportSummaryService {
  const ReportSummaryService(this._repository);

  final ReportRepository _repository;

  Future<RevenueSummary> revenueSummary({
    String? routerId,
    required ReportPeriod period,
    DateTime? now,
  }) async {
    final range = ReportDateRange.forPeriod(period, now: now);
    final sales = await _repository.getSales(
      routerId: routerId,
      from: range.from,
      to: range.to,
    );
    final total = sales.fold<int>(
      0,
      (previous, sale) => previous + sale.amountMinor,
    );
    return RevenueSummary(
      sales: sales,
      totalMinor: total,
      currency: sales.isEmpty ? 'NGN' : sales.first.currency,
      from: range.from,
      to: range.to,
    );
  }
}
