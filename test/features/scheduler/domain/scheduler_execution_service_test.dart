import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/reports/domain/entities/sale_entity.dart';
import 'package:wirespot/features/reports/domain/repositories/report_repository.dart';
import 'package:wirespot/features/reports/domain/services/report_summary_service.dart';
import 'package:wirespot/features/scheduler/domain/entities/scheduled_task.dart';
import 'package:wirespot/features/scheduler/domain/services/scheduler_execution_service.dart';
import 'package:wirespot/features/scheduler/domain/services/scheduler_settings_service.dart';
import 'package:wirespot/features/settings/domain/entities/printer_config_entity.dart';
import 'package:wirespot/features/settings/domain/repositories/settings_repository.dart';
import 'package:wirespot/features/settings/domain/services/backup_service.dart';

void main() {
  test('runs due enabled scheduler tasks and records status', () async {
    final settings = _FakeSettingsRepository()
      ..values['scheduler.dailySalesSummary.enabled'] = 'true'
      ..values['scheduler.dailySalesSummary.intervalMinutes'] = '1440'
      ..values['scheduler.databaseBackup.enabled'] = 'true'
      ..values['scheduler.databaseBackup.intervalMinutes'] = '1440';
    final service = _service(settings);

    final results = await service.runDueTasks(now: DateTime(2026, 7, 13, 12));

    expect(
      results.map((result) => result.type),
      containsAll([
        ScheduledTaskType.dailySalesSummary,
        ScheduledTaskType.databaseBackup,
      ]),
    );
    expect(
      settings.values['scheduler.dailySalesSummary.lastRunStatus'],
      contains('Daily sales: 1 transactions'),
    );
    expect(
      settings.values['scheduler.databaseBackup.lastRunStatus'],
      contains('Backup snapshot ready'),
    );
  });

  test('skips enabled tasks that are not due yet', () async {
    final settings = _FakeSettingsRepository()
      ..values['scheduler.dailySalesSummary.enabled'] = 'true'
      ..values['scheduler.dailySalesSummary.intervalMinutes'] = '60'
      ..values['scheduler.dailySalesSummary.lastRunAt'] = DateTime(
        2026,
        7,
        13,
        11,
        30,
      ).toIso8601String();
    final service = _service(settings);

    final results = await service.runDueTasks(now: DateTime(2026, 7, 13, 12));

    expect(results, isEmpty);
  });
}

SchedulerExecutionService _service(_FakeSettingsRepository settings) {
  return SchedulerExecutionService(
    settingsService: SchedulerSettingsService(settings),
    backupService: BackupService(settings),
    reportSummaryService: ReportSummaryService(_FakeReportRepository()),
  );
}

class _FakeSettingsRepository implements SettingsRepository {
  final values = <String, String>{};

  @override
  Future<String?> readSetting(String key) async => values[key];

  @override
  Future<void> writeSetting(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> deletePrinter(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<PrinterConfigEntity>> getPrinters() async {
    return const [
      PrinterConfigEntity(
        id: 'printer-1',
        name: 'Field Printer',
        address: 'AA:BB:CC:DD:EE:FF',
      ),
    ];
  }

  @override
  Future<void> savePrinter(PrinterConfigEntity printer) {
    throw UnimplementedError();
  }
}

class _FakeReportRepository implements ReportRepository {
  @override
  Future<List<SaleEntity>> getSales({
    String? routerId,
    DateTime? from,
    DateTime? to,
  }) async {
    return [
      SaleEntity(
        id: 'sale-1',
        routerId: 'router-1',
        amountMinor: 50000,
        currency: 'NGN',
        soldAt: DateTime(2026, 7, 13, 10),
      ),
    ];
  }

  @override
  Future<void> recordSale(SaleEntity sale) {
    throw UnimplementedError();
  }
}
