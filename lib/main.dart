import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'features/cloud/domain/services/cloud_backup_service.dart';
import 'features/scheduler/domain/services/scheduler_execution_service.dart';
import 'features/settings/domain/services/backup_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  sl<SchedulerExecutionService>().start();
  
  // Try local side-loaded backup first
  final localRestored = await sl<BackupService>().autoRestoreIfBackupFound();
  
  // If local backup wasn't found and restored, try cloud backup
  if (!localRestored) {
    // Cloud auto-restore fails silently if no cloud backup exists or user not signed in
    await sl<CloudBackupService>().autoRestoreFromCloudIfLocalEmpty();
  }

  runApp(const ProviderScope(child: WireSpotApp()));
}
