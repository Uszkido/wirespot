import 'package:flutter_riverpod/legacy.dart';

import '../data/cloud_api_client.dart';
import '../domain/entities/cloud_connection_settings.dart';
import '../domain/entities/cloud_session.dart';
import '../domain/entities/cloud_sync_operation.dart';
import '../domain/repositories/cloud_sync_repository.dart';
import '../domain/services/cloud_settings_service.dart';
import '../domain/services/cloud_sync_service.dart';

class CloudState {
  const CloudState({
    this.connection,
    this.session,
    this.pendingOperations = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.isSyncing = false,
    this.isTestingConnection = false,
    this.connectionHealthy,
  });

  final CloudConnectionSettings? connection;
  final CloudSession? session;
  final List<CloudSyncOperation> pendingOperations;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool isSyncing;
  final bool isTestingConnection;
  final bool? connectionHealthy;

  CloudState copyWith({
    CloudConnectionSettings? Function()? connection,
    CloudSession? Function()? session,
    List<CloudSyncOperation>? pendingOperations,
    bool? isLoading,
    String? Function()? errorMessage,
    String? Function()? successMessage,
    bool? isSyncing,
    bool? isTestingConnection,
    bool? Function()? connectionHealthy,
  }) {
    return CloudState(
      connection: connection != null ? connection() : this.connection,
      session: session != null ? session() : this.session,
      pendingOperations: pendingOperations ?? this.pendingOperations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      successMessage:
          successMessage != null ? successMessage() : this.successMessage,
      isSyncing: isSyncing ?? this.isSyncing,
      isTestingConnection: isTestingConnection ?? this.isTestingConnection,
      connectionHealthy: connectionHealthy != null
          ? connectionHealthy()
          : this.connectionHealthy,
    );
  }
}

class CloudController extends StateNotifier<CloudState> {
  CloudController({
    required CloudSettingsService settingsService,
    required CloudSyncRepository syncRepository,
    required CloudSyncService syncService,
    required CloudApiClient apiClient,
  }) : _settingsService = settingsService,
       _syncRepository = syncRepository,
       _syncService = syncService,
       _apiClient = apiClient,
       super(const CloudState()) {
    load();
  }

  final CloudSettingsService _settingsService;
  final CloudSyncRepository _syncRepository;
  final CloudSyncService _syncService;
  final CloudApiClient _apiClient;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final connection = await _settingsService.loadConnection();
      final session = await _settingsService.loadSession();
      final pending = await _syncRepository.pendingOperations();
      state = state.copyWith(
        connection: () => connection,
        session: () => session,
        pendingOperations: pending,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => error.toString(),
      );
    }
  }

  Future<bool> testConnection() async {
    state = state.copyWith(
      isTestingConnection: true,
      errorMessage: () => null,
      successMessage: () => null,
      connectionHealthy: () => null,
    );
    try {
      final healthy = await _apiClient.testConnection();
      state = state.copyWith(
        isTestingConnection: false,
        connectionHealthy: () => healthy,
        successMessage: () => healthy
            ? 'WireSpot Cloud connection test successful!'
            : 'Cloud connection unreachable or unauthorized.',
      );
      return healthy;
    } catch (error) {
      state = state.copyWith(
        isTestingConnection: false,
        connectionHealthy: () => false,
        errorMessage: () => 'Connection test failed: $error',
      );
      return false;
    }
  }

  Future<bool> saveConnection(CloudConnectionSettings settings) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: () => null,
      successMessage: () => null,
    );
    try {
      await _settingsService.saveConnection(settings);
      await load();
      state = state.copyWith(
        successMessage: () => 'Cloud connection settings saved successfully.',
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => error.toString(),
      );
      return false;
    }
  }

  Future<bool> saveSession(String accessToken, int expiryMinutes) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: () => null,
      successMessage: () => null,
    );
    try {
      if (accessToken.trim().isEmpty) {
        throw ArgumentError('Access token cannot be empty.');
      }
      final session = CloudSession(
        accessToken: accessToken.trim(),
        expiresAt: DateTime.now().add(Duration(minutes: expiryMinutes)),
      );
      await _settingsService.saveSession(session);
      await load();
      state = state.copyWith(
        successMessage: () => 'Cloud session activated.',
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => error.toString(),
      );
      return false;
    }
  }

  Future<void> clearSession() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: () => null,
      successMessage: () => null,
    );
    try {
      await _settingsService.clearSession();
      await load();
      state = state.copyWith(
        successMessage: () => 'Disconnected from WireSpot Cloud session.',
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => error.toString(),
      );
    }
  }

  Future<void> syncPending() async {
    if (state.isSyncing) return;
    state = state.copyWith(
      isSyncing: true,
      errorMessage: () => null,
      successMessage: () => null,
    );
    try {
      final synchronized = await _syncService.syncPending();
      final pending = await _syncRepository.pendingOperations();
      state = state.copyWith(
        isSyncing: false,
        pendingOperations: pending,
        successMessage: () => 'Synchronized $synchronized operation(s).',
      );
    } catch (error) {
      final pending = await _syncRepository.pendingOperations();
      state = state.copyWith(
        isSyncing: false,
        pendingOperations: pending,
        errorMessage: () => 'Sync failed: $error',
      );
    }
  }

  Future<void> retryFailed() async {
    state = state.copyWith(errorMessage: () => null, successMessage: () => null);
    try {
      final count = await _syncRepository.retryFailed();
      final pending = await _syncRepository.pendingOperations();
      state = state.copyWith(
        pendingOperations: pending,
        successMessage: () => 'Reset $count failed operation(s) to pending.',
      );
    } catch (error) {
      state = state.copyWith(errorMessage: () => 'Failed to retry: $error');
    }
  }

  Future<void> clearCompleted() async {
    state = state.copyWith(errorMessage: () => null, successMessage: () => null);
    try {
      final count = await _syncRepository.clearCompleted();
      final pending = await _syncRepository.pendingOperations();
      state = state.copyWith(
        pendingOperations: pending,
        successMessage: () => 'Cleared $count completed operation(s).',
      );
    } catch (error) {
      state = state.copyWith(errorMessage: () => 'Failed to clear: $error');
    }
  }
}
