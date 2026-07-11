import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/printer_config_entity.dart';

final appSettingsProvider = FutureProvider.autoDispose<AppSettingsSnapshot>(
  (ref) => ref.watch(appSettingsServiceProvider).load(),
);

final printerConfigsProvider =
    FutureProvider.autoDispose<List<PrinterConfigEntity>>(
  (ref) => ref.watch(settingsRepositoryProvider).getPrinters(),
);
