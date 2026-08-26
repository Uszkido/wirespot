import '../entities/revenue_summary.dart';
import '../../../voucher/domain/entities/voucher_entity.dart';

class TelemetryAnalytics {
  const TelemetryAnalytics({
    required this.arpuMajor,
    required this.peakHourLabel,
    required this.lowVoucherWarnings,
    required this.hourlySalesDistribution,
  });

  final double arpuMajor;
  final String peakHourLabel;
  final List<String> lowVoucherWarnings;
  final Map<int, int> hourlySalesDistribution;
}

class TelemetryAnalyticsService {
  const TelemetryAnalyticsService();

  TelemetryAnalytics analyze({
    required RevenueSummary summary,
    required List<VoucherEntity> vouchers,
    int lowStockThreshold = 5,
  }) {
    final hourlySales = <int, int>{};
    for (var i = 0; i < 24; i++) {
      hourlySales[i] = 0;
    }

    for (final sale in summary.sales) {
      final hour = sale.soldAt.hour;
      hourlySales[hour] = (hourlySales[hour] ?? 0) + 1;
    }

    var peakHour = 0;
    var maxSales = 0;
    hourlySales.forEach((hour, count) {
      if (count > maxSales) {
        maxSales = count;
        peakHour = hour;
      }
    });

    final peakLabel = maxSales > 0
        ? '${peakHour.toString().padLeft(2, '0')}:00 - ${(peakHour + 1).toString().padLeft(2, '0')}:00 ($maxSales sales)'
        : 'No peak traffic recorded';

    final totalUsers = summary.sales.map((s) => s.routerId).toSet().length;
    final arpu = totalUsers > 0 ? (summary.totalMajor / totalUsers) : 0.0;

    final unusedVouchersByProfile = <String, int>{};
    for (final voucher in vouchers.where(
      (v) => v.soldAt == null && v.printedAt == null,
    )) {
      final profile = voucher.profileId ?? 'Default';
      unusedVouchersByProfile[profile] =
          (unusedVouchersByProfile[profile] ?? 0) + 1;
    }

    final warnings = <String>[];
    unusedVouchersByProfile.forEach((profile, count) {
      if (count <= lowStockThreshold) {
        warnings.add(
          'Low voucher inventory for profile "$profile": only $count unused remaining.',
        );
      }
    });

    return TelemetryAnalytics(
      arpuMajor: arpu,
      peakHourLabel: peakLabel,
      lowVoucherWarnings: warnings,
      hourlySalesDistribution: hourlySales,
    );
  }
}
