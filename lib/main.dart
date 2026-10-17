import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'features/cloud/domain/services/cloud_backup_service.dart';
import 'features/scheduler/domain/services/scheduler_execution_service.dart';
import 'features/settings/domain/services/backup_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure the bundled SQLite shared library is loaded before Drift spawns
  // its database isolate. This is required on Android versions that cannot
  // resolve APK-provided native libraries through the default loader.
  try {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  } on Object {
    // Keep the app launchable so a useful error can be shown if the platform
    // cannot load SQLite; normal Android versions load the bundled library.
  }
  await configureDependencies();
  sl<SchedulerExecutionService>().start();

  // Render the first screen immediately. Cloud/local backup restore is a
  // best-effort enhancement and must never hold the Android launch screen
  // while the device is offline or the API is waking from free-tier sleep.
  runApp(const ProviderScope(child: WireSpotApp()));
  unawaited(_restoreBackupsInBackground());
}

Future<void> _restoreBackupsInBackground() async {
  // Try local side-loaded backup first
  try {
    final localRestored = await sl<BackupService>()
        .autoRestoreIfBackupFound()
        .timeout(const Duration(seconds: 5));

    // If local backup wasn't found and restored, try cloud backup. A timeout
    // keeps startup responsive when no cloud account has been configured.
    if (!localRestored) {
      await sl<CloudBackupService>().autoRestoreFromCloudIfLocalEmpty().timeout(
        const Duration(seconds: 5),
      );
    }
  } on Object {
    // Restore is optional; the app remains usable with local empty state.
  }
}
