import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/licensing/entitlement_snapshot.dart';
import '../../scheduler/domain/entities/scheduled_task.dart';
import '../../voucher/domain/entities/voucher_encoding_settings.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/printer_config_entity.dart';

final appSettingsProvider = FutureProvider.autoDispose<AppSettingsSnapshot>(
  (ref) => ref.watch(appSettingsServiceProvider).load(),
);

final printerConfigsProvider =
    FutureProvider.autoDispose<List<PrinterConfigEntity>>(
      (ref) => ref.watch(settingsRepositoryProvider).getPrinters(),
    );

final entitlementSnapshotProvider =
    FutureProvider.autoDispose<EntitlementSnapshot>(
      (ref) => ref.watch(entitlementServiceProvider).load(),
    );

final voucherEncodingSettingsProvider =
    FutureProvider.autoDispose<VoucherEncodingSettings>(
      (ref) => ref.watch(voucherEncodingSettingsServiceProvider).load(),
    );

final schedulerTasksProvider = FutureProvider.autoDispose<List<ScheduledTask>>(
  (ref) => ref.watch(schedulerSettingsServiceProvider).load(),
);
