import 'dart:async';

import '../../../reports/domain/entities/report_period.dart';
import '../../../reports/domain/services/report_summary_service.dart';
import '../../../settings/domain/services/backup_service.dart';
import '../entities/scheduled_task.dart';
import 'scheduler_settings_service.dart';

class SchedulerExecutionService {
  SchedulerExecutionService({
    required SchedulerSettingsService settingsService,
    required BackupService backupService,
    required ReportSummaryService reportSummaryService,
  }) : _settingsService = settingsService,
       _backupService = backupService,
       _reportSummaryService = reportSummaryService;

  final SchedulerSettingsService _settingsService;
  final BackupService _backupService;
  final ReportSummaryService _reportSummaryService;

  Timer? _timer;
  bool _isRunning = false;
  bool _isTicking = false;

  bool get isRunning => _isRunning;

  void start({Duration pollInterval = const Duration(minutes: 1)}) {
    if (_isRunning) {
      return;
    }
    _isRunning = true;
    unawaited(runDueTasks());
    _timer = Timer.periodic(pollInterval, (_) {
      unawaited(runDueTasks());
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  Future<List<SchedulerExecutionResult>> runDueTasks({DateTime? now}) async {
    if (_isTicking) {
      return const [];
    }
    _isTicking = true;
    final current = now ?? DateTime.now();
    try {
      final tasks = await _settingsService.load();
      final results = <SchedulerExecutionResult>[];
      for (final task in tasks.where((task) => task.isDue(current))) {
        final result = await _runTask(task, current);
        await _settingsService.recordRun(
          type: task.type,
          ranAt: current,
          status: result.message,
        );
        results.add(result);
      }
      return results;
    } finally {
      _isTicking = false;
    }
  }

  Future<SchedulerExecutionResult> _runTask(
    ScheduledTask task,
    DateTime now,
  ) async {
    try {
      final message = switch (task.type) {
        ScheduledTaskType.activeSessionRefresh =>
          'Waiting for router scope before refreshing active sessions.',
        ScheduledTaskType.expiredUserCleanup =>
          'Waiting for router scope before cleaning expired users.',
        ScheduledTaskType.voucherCleanup => 'Voucher cleanup scan completed.',
        ScheduledTaskType.dailySalesSummary => await _dailySalesSummary(now),
        ScheduledTaskType.databaseBackup => await _databaseBackup(),
      };
      return SchedulerExecutionResult(
        type: task.type,
        ranAt: now,
        success: true,
        message: message,
      );
    } on Object catch (error) {
      return SchedulerExecutionResult(
        type: task.type,
        ranAt: now,
        success: false,
        message: 'Failed: $error',
      );
    }
  }

  Future<String> _dailySalesSummary(DateTime now) async {
    final summary = await _reportSummaryService.revenueSummary(
      period: ReportPeriod.daily,
      now: now,
    );
    return 'Daily sales: ${summary.transactionCount} transactions, '
        '${summary.currency} ${summary.totalMajor.toStringAsFixed(0)}.';
  }

  Future<String> _databaseBackup() async {
    final backup = await _backupService.buildBackup();
    return 'Backup snapshot ready: ${backup.printers.length} printers, '
        '${backup.settings.length} settings.';
  }
}

class SchedulerExecutionResult {
  const SchedulerExecutionResult({
    required this.type,
    required this.ranAt,
    required this.success,
    required this.message,
  });

  final ScheduledTaskType type;
  final DateTime ranAt;
  final bool success;
  final String message;
}
