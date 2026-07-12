enum ScheduledTaskType {
  activeSessionRefresh,
  expiredUserCleanup,
  voucherCleanup,
  dailySalesSummary,
  databaseBackup,
}

class ScheduledTask {
  const ScheduledTask({
    required this.type,
    required this.enabled,
    required this.intervalMinutes,
  });

  final ScheduledTaskType type;
  final bool enabled;
  final int intervalMinutes;

  String get label {
    return switch (type) {
      ScheduledTaskType.activeSessionRefresh => 'Active session refresh',
      ScheduledTaskType.expiredUserCleanup => 'Expired user cleanup',
      ScheduledTaskType.voucherCleanup => 'Voucher cleanup',
      ScheduledTaskType.dailySalesSummary => 'Daily sales summary',
      ScheduledTaskType.databaseBackup => 'Database backup',
    };
  }

  ScheduledTask copyWith({bool? enabled, int? intervalMinutes}) {
    return ScheduledTask(
      type: type,
      enabled: enabled ?? this.enabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
    );
  }

  static List<ScheduledTask> defaults() {
    return const [
      ScheduledTask(
        type: ScheduledTaskType.activeSessionRefresh,
        enabled: false,
        intervalMinutes: 5,
      ),
      ScheduledTask(
        type: ScheduledTaskType.expiredUserCleanup,
        enabled: false,
        intervalMinutes: 60,
      ),
      ScheduledTask(
        type: ScheduledTaskType.voucherCleanup,
        enabled: false,
        intervalMinutes: 1440,
      ),
      ScheduledTask(
        type: ScheduledTaskType.dailySalesSummary,
        enabled: false,
        intervalMinutes: 1440,
      ),
      ScheduledTask(
        type: ScheduledTaskType.databaseBackup,
        enabled: false,
        intervalMinutes: 1440,
      ),
    ];
  }
}
