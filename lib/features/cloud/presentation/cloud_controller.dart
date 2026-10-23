import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';

import '../data/cloud_api_client.dart';
import '../domain/entities/cloud_connection_settings.dart';
import '../domain/entities/cloud_session.dart';
import '../../authentication/domain/entities/operator_role.dart';
import '../domain/entities/cloud_sync_operation.dart';
import '../domain/repositories/cloud_sync_repository.dart';
import '../domain/services/cloud_settings_service.dart';
import '../domain/services/cloud_sync_service.dart';
import '../domain/services/cloud_backup_service.dart';
import '../domain/services/cloud_telemetry_service.dart';

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
      successMessage: successMessage != null
          ? successMessage()
          : this.successMessage,
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
    CloudBackupService? backupService,
    CloudTelemetryService? telemetryService,
  }) : _settingsService = settingsService,
       _syncRepository = syncRepository,
       _syncService = syncService,
       _apiClient = apiClient,
       _backupService = backupService,
       _telemetryService = telemetryService,
       super(const CloudState()) {
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (state.session != null && !state.isSyncing) {
        unawaited(_collectTelemetryAndSync());
      }
    });
    load();
  }

  final CloudSettingsService _settingsService;
  final CloudSyncRepository _syncRepository;
  final CloudSyncService _syncService;
  final CloudApiClient _apiClient;
  final CloudBackupService? _backupService;
  final CloudTelemetryService? _telemetryService;
  Timer? _autoSyncTimer;

  Future<void> _collectTelemetryAndSync() async {
    try {
      await _telemetryService?.collectAndPostTelemetry();
    } finally {
      await syncPending();
    }
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    super.dispose();
  }

  /// Restores the latest organization workspace after authentication when the
  /// local database is empty (for example, on a newly paired Windows device).
  /// A restore failure must not invalidate a successful sign-in.
  Future<void> _restoreCloudWorkspaceIfEmpty() async {
    final backupService = _backupService;
    if (backupService == null) return;
    try {
      final restored = await backupService.autoRestoreFromCloudIfLocalEmpty();
      if (restored) {
        await load();
      }
    } on Object {
      // Authentication remains successful even when the backup endpoint is
      // temporarily unavailable. The user can retry from the sync card.
    }
  }

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
      state = state.copyWith(successMessage: () => 'Cloud session activated.');
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => error.toString(),
      );
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: () => null,
      successMessage: () => null,
    );
    try {
      final data = await _apiClient.login(email, password);
      final token = data['accessToken'] as String? ?? '';
      final user = data['user'] as Map<String, dynamic>? ?? {};
      final orgId = user['organizationId'] as String?;
      final role = OperatorRoleWireValue.fromWireValue(user['role'] as String?);

      if (token.isEmpty) {
        throw StateError('Invalid credentials or session token missing.');
      }

      if (orgId != null && orgId.isNotEmpty) {
        final currentConn =
            state.connection ??
            const CloudConnectionSettings(
              apiBaseUrl: 'https://cloud.wirespot.app/api',
            );
        await _settingsService.saveConnection(
          currentConn.copyWith(organizationId: orgId),
        );
      }

      final session = CloudSession(
        accessToken: token,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        role: role,
      );
      await _settingsService.saveSession(session);
      await load();
      await _restoreCloudWorkspaceIfEmpty();
      state = state.copyWith(
        successMessage: () => 'Welcome back! Signed in as $email.',
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Sign in failed: ${error.toString()}',
      );
      return false;
    }
  }

  Future<bool> pairCompanion(String pairingKey) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: () => null,
      successMessage: () => null,
    );
    try {
      final data = await _apiClient.pairDevice(
        pairingKey.trim(),
        organizationId: state.connection?.organizationId,
      );
      final token = data['accessToken'] as String? ?? '';
      final orgId = data['organizationId'] as String?;
      final expiresIn = (data['expiresIn'] as num?)?.toInt() ?? 1440;
      if (token.isEmpty) throw StateError('Pairing did not return a session.');
      final current =
          state.connection ??
          const CloudConnectionSettings(
            apiBaseUrl: 'https://wirespot-api.onrender.com',
          );
      await _settingsService.saveConnection(
        current.copyWith(organizationId: orgId),
      );
      await _settingsService.saveSession(
        CloudSession(
          accessToken: token,
          expiresAt: DateTime.now().add(Duration(minutes: expiresIn)),
        ),
      );
      await load();
      await _restoreCloudWorkspaceIfEmpty();
      state = state.copyWith(
        successMessage: () => 'Companion device paired successfully.',
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Pairing failed: ${error.toString()}',
      );
      return false;
    }
  }

  Future<String?> createCompanionCode() async {
    try {
      final data = await _apiClient.createPairingCode();
      return data['pairingKey'] as String?;
    } catch (error) {
      state = state.copyWith(
        errorMessage: () => 'Could not create pairing code: $error',
      );
      return null;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String organizationName,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: () => null,
      successMessage: () => null,
    );
    try {
      final data = await _apiClient.register(
        email: email,
        password: password,
        organizationName: organizationName,
      );
      final token = data['accessToken'] as String? ?? '';
      final user = data['user'] as Map<String, dynamic>? ?? {};
      final orgId = user['organizationId'] as String?;
      final role = OperatorRoleWireValue.fromWireValue(user['role'] as String?);

      if (token.isEmpty) {
        throw StateError('Registration failed to yield a valid token.');
      }

      if (orgId != null && orgId.isNotEmpty) {
        final currentConn =
            state.connection ??
            const CloudConnectionSettings(
              apiBaseUrl: 'https://cloud.wirespot.app/api',
            );
        await _settingsService.saveConnection(
          currentConn.copyWith(organizationId: orgId),
        );
      }

      final session = CloudSession(
        accessToken: token,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        role: role,
      );
      await _settingsService.saveSession(session);
      await load();
      await _restoreCloudWorkspaceIfEmpty();
      state = state.copyWith(
        successMessage: () => 'Account created! Signed in as $email.',
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Sign up failed: ${error.toString()}',
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
      final bidirectional = await _backupService?.syncBidirectional() ?? false;
      final pending = await _syncRepository.pendingOperations();
      state = state.copyWith(
        isSyncing: false,
        pendingOperations: pending,
        successMessage: () => bidirectional
            ? 'Synchronized $synchronized operation(s) and merged the workspace.'
            : 'Synchronized $synchronized operation(s).',
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

  /// Explicitly replaces an empty/local workspace with the latest cloud
  /// backup. This is useful on companion devices and is never run silently
  /// when local router data already exists.
  Future<void> restoreLatestBackup() async {
    final backupService = _backupService;
    if (backupService == null || state.isSyncing) return;
    state = state.copyWith(
      isSyncing: true,
      errorMessage: () => null,
      successMessage: () => null,
    );
    try {
      final restored = await backupService.restoreFromCloud();
      await load();
      state = state.copyWith(
        isSyncing: false,
        successMessage: () => restored
            ? 'Latest cloud workspace restored.'
            : 'No cloud backup is available yet.',
      );
    } catch (error) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: () => 'Cloud restore failed: $error',
      );
    }
  }

  Future<void> retryFailed() async {
    state = state.copyWith(
      errorMessage: () => null,
      successMessage: () => null,
    );
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
    state = state.copyWith(
      errorMessage: () => null,
      successMessage: () => null,
    );
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
