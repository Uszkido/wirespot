enum ReportPeriod { daily, weekly, monthly }

class ReportDateRange {
  const ReportDateRange({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  factory ReportDateRange.forPeriod(ReportPeriod period, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final todayStart = DateTime(current.year, current.month, current.day);
    return switch (period) {
      ReportPeriod.daily => ReportDateRange(from: todayStart, to: current),
      ReportPeriod.weekly => ReportDateRange(
        from: todayStart.subtract(Duration(days: current.weekday - 1)),
        to: current,
      ),
      ReportPeriod.monthly => ReportDateRange(
        from: DateTime(current.year, current.month),
        to: current,
      ),
    };
  }
}
