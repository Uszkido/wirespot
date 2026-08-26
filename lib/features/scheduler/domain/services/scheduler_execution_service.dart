import 'dart:async';

import '../../../cloud/domain/services/cloud_backup_service.dart';
import '../../../cloud/domain/services/cloud_sync_service.dart';
import '../../../hotspot/domain/entities/hotspot_active_session_entity.dart';
import '../../../hotspot/domain/services/hotspot_service.dart';
import '../../../reports/domain/entities/report_period.dart';
import '../../../reports/domain/services/report_summary_service.dart';
import '../../../routers/domain/entities/router_entity.dart';
import '../../../routers/domain/repositories/router_repository.dart';
import '../../../settings/domain/services/backup_service.dart';
import '../../../voucher/domain/entities/voucher_entity.dart';
import '../../../voucher/domain/repositories/voucher_repository.dart';
import '../entities/scheduled_task.dart';
import 'scheduler_settings_service.dart';

class SchedulerExecutionService {
  SchedulerExecutionService({
    required SchedulerSettingsService settingsService,
    required BackupService backupService,
    required ReportSummaryService reportSummaryService,
    required RouterRepository routerRepository,
    required HotspotService hotspotService,
    required VoucherRepository voucherRepository,
    CloudSyncService? cloudSyncService,
    CloudBackupService? cloudBackupService,
  }) : _settingsService = settingsService,
       _backupService = backupService,
       _reportSummaryService = reportSummaryService,
       _routerRepository = routerRepository,
       _hotspotService = hotspotService,
       _voucherRepository = voucherRepository,
       _cloudSyncService = cloudSyncService,
       _cloudBackupService = cloudBackupService;

  final SchedulerSettingsService _settingsService;
  final BackupService _backupService;
  final ReportSummaryService _reportSummaryService;
  final RouterRepository _routerRepository;
  final HotspotService _hotspotService;
  final VoucherRepository _voucherRepository;
  final CloudSyncService? _cloudSyncService;
  final CloudBackupService? _cloudBackupService;

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
        ScheduledTaskType.activeSessionRefresh => await _activeSessionRefresh(),
        ScheduledTaskType.expiredUserCleanup => await _expiredSessionCleanup(),
        ScheduledTaskType.voucherCleanup => await _voucherCleanup(now),
        ScheduledTaskType.dailySalesSummary => await _dailySalesSummary(now),
        ScheduledTaskType.databaseBackup => await _databaseBackup(),
        ScheduledTaskType.cloudSync => await _cloudSync(),
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

  Future<String> _activeSessionRefresh() async {
    final routers = await _enabledRouters();
    if (routers.isEmpty) {
      return 'No enabled routers available for active session refresh.';
    }

    var reachableRouters = 0;
    var activeSessions = 0;
    final failures = <String>[];
    for (final router in routers) {
      try {
        final sessions = await _hotspotService.getActiveSessions(router);
        reachableRouters += 1;
        activeSessions += sessions.length;
      } on Object catch (error) {
        failures.add('${router.name}: $error');
      }
    }

    return _routerTaskMessage(
      action: 'Active session refresh',
      reachableRouters: reachableRouters,
      totalRouters: routers.length,
      details: '$activeSessions active sessions found',
      failures: failures,
    );
  }

  Future<String> _expiredSessionCleanup() async {
    final routers = await _enabledRouters();
    if (routers.isEmpty) {
      return 'No enabled routers available for expired session cleanup.';
    }

    var reachableRouters = 0;
    var disconnectedSessions = 0;
    final failures = <String>[];
    for (final router in routers) {
      try {
        final sessions = await _hotspotService.getActiveSessions(router);
        reachableRouters += 1;
        final expiredSessions = sessions.where(_isExpiredSession).toList();
        for (final session in expiredSessions) {
          await _hotspotService.disconnectSession(router, session.id);
        }
        disconnectedSessions += expiredSessions.length;
      } on Object catch (error) {
        failures.add('${router.name}: $error');
      }
    }

    return _routerTaskMessage(
      action: 'Expired session cleanup',
      reachableRouters: reachableRouters,
      totalRouters: routers.length,
      details: '$disconnectedSessions expired sessions disconnected',
      failures: failures,
    );
  }

  Future<String> _cloudSync() async {
    if (_cloudSyncService == null) {
      return 'Cloud sync service unavailable.';
    }
    final count = await _cloudSyncService.syncPending();
    return 'Cloud sync synchronized $count pending operation(s).';
  }

  Future<String> _databaseBackup() async {
    final backup = await _backupService.buildBackup();
    var cloudStatus = '';
    if (_cloudBackupService != null) {
      try {
        final uploaded = await _cloudBackupService.uploadCloudBackup();
        cloudStatus = uploaded
            ? ' & uploaded to cloud'
            : ' (cloud upload failed)';
      } catch (e) {
        cloudStatus = ' (cloud upload error)';
      }
    }
    return 'Backup snapshot ready: ${backup.printers.length} printers, '
        '${backup.settings.length} settings$cloudStatus.';
  }

  Future<String> _voucherCleanup(DateTime now) async {
    final vouchers = await _voucherRepository.getVoucherHistory();
    final expiredVoucherIds = vouchers
        .where((voucher) => _isExpiredUnusedVoucher(voucher, now))
        .map((voucher) => voucher.id)
        .toList();
    await _voucherRepository.deleteVouchers(expiredVoucherIds);
    final label = expiredVoucherIds.length == 1 ? 'voucher' : 'vouchers';
    return 'Voucher cleanup removed ${expiredVoucherIds.length} expired '
        'unused $label from local history.';
  }

  Future<List<RouterEntity>> _enabledRouters() async {
    final routers = await _routerRepository.getRouters();
    return routers.where((router) => router.isEnabled).toList();
  }

  bool _isExpiredSession(HotspotActiveSessionEntity session) {
    final timeLeft = session.sessionTimeLeft?.trim().toLowerCase();
    if (timeLeft == null || timeLeft.isEmpty) {
      return false;
    }
    return timeLeft == '0' ||
        timeLeft == '0s' ||
        timeLeft == '00:00:00' ||
        timeLeft == '0:00:00';
  }

  bool _isExpiredUnusedVoucher(VoucherEntity voucher, DateTime now) {
    final validityMinutes = voucher.validityMinutes;
    if (validityMinutes == null || validityMinutes <= 0) {
      return false;
    }
    if (voucher.soldAt != null || voucher.printedAt != null) {
      return false;
    }
    final expiresAt = voucher.generatedAt.add(
      Duration(minutes: validityMinutes),
    );
    return !expiresAt.isAfter(now);
  }

  String _routerTaskMessage({
    required String action,
    required int reachableRouters,
    required int totalRouters,
    required String details,
    required List<String> failures,
  }) {
    final buffer = StringBuffer(
      '$action completed on $reachableRouters/$totalRouters routers; $details.',
    );
    if (failures.isNotEmpty) {
      buffer.write(' Failures: ${failures.take(3).join('; ')}');
      if (failures.length > 3) {
        buffer.write(' and ${failures.length - 3} more');
      }
      buffer.write('.');
    }
    return buffer.toString();
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
