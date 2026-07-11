import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/di/providers.dart';
import '../domain/entities/report_period.dart';
import '../domain/entities/revenue_summary.dart';

final selectedReportRouterIdProvider = StateProvider<String?>((ref) => null);

final selectedReportPeriodProvider = StateProvider<ReportPeriod>(
  (ref) => ReportPeriod.daily,
);

final revenueSummaryProvider =
    FutureProvider.autoDispose<RevenueSummary>((ref) {
  final routerId = ref.watch(selectedReportRouterIdProvider);
  final period = ref.watch(selectedReportPeriodProvider);
  return ref.watch(reportSummaryServiceProvider).revenueSummary(
        routerId: routerId,
        period: period,
      );
});
