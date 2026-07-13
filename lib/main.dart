import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'features/scheduler/domain/services/scheduler_execution_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  sl<SchedulerExecutionService>().start();

  runApp(const ProviderScope(child: WireSpotApp()));
}
