import 'package:flutter_riverpod/legacy.dart';

import '../../../core/di/providers.dart';
import 'cloud_controller.dart';

final cloudControllerProvider =
    StateNotifierProvider<CloudController, CloudState>((ref) {
      return CloudController(
        settingsService: ref.watch(cloudSettingsServiceProvider),
        syncRepository: ref.watch(cloudSyncRepositoryProvider),
        syncService: ref.watch(cloudSyncServiceProvider),
        apiClient: ref.watch(cloudApiClientProvider),
      );
    });
