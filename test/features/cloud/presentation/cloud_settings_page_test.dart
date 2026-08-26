import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/cloud/data/cloud_api_client.dart';
import 'package:wirespot/features/cloud/domain/entities/cloud_connection_settings.dart';
import 'package:wirespot/features/cloud/domain/entities/cloud_session.dart';
import 'package:wirespot/features/cloud/domain/entities/cloud_sync_operation.dart';
import 'package:wirespot/features/cloud/domain/repositories/cloud_sync_repository.dart';
import 'package:wirespot/features/cloud/domain/services/cloud_settings_service.dart';
import 'package:wirespot/features/cloud/domain/services/cloud_sync_service.dart';
import 'package:wirespot/features/cloud/presentation/cloud_controller.dart';
import 'package:wirespot/features/cloud/presentation/cloud_providers.dart';
import 'package:wirespot/features/cloud/presentation/cloud_settings_page.dart';
import 'package:wirespot/features/settings/domain/entities/app_settings.dart';
import 'package:wirespot/features/settings/presentation/settings_providers.dart';

class FakeCloudSettingsService implements CloudSettingsService {
  CloudConnectionSettings? _connection = const CloudConnectionSettings(
    apiBaseUrl: 'https://cloud.wirespot.app/api',
    organizationId: 'org_test123',
  );
  CloudSession? _session;

  @override
  Future<CloudConnectionSettings?> loadConnection() async => _connection;

  @override
  Future<void> saveConnection(CloudConnectionSettings settings) async {
    _connection = settings;
  }

  @override
  Future<CloudSession?> loadSession() async => _session;

  @override
  Future<void> saveSession(CloudSession session) async {
    _session = session;
  }

  @override
  Future<void> clearSession() async {
    _session = null;
  }
}

class FakeSyncRepository implements CloudSyncRepository {
  final List<CloudSyncOperation> _ops = [];

  @override
  Future<void> enqueue(CloudSyncOperation operation) async {
    _ops.add(operation);
  }

  @override
  Future<List<CloudSyncOperation>> pendingOperations() async => _ops;

  @override
  Future<void> markSyncing(String id) async {}

  @override
  Future<void> markCompleted(String id) async {}

  @override
  Future<void> markFailed(String id, String error) async {}

  @override
  Future<int> clearCompleted() async => 0;

  @override
  Future<int> retryFailed() async => 0;
}

class FakeApiClient implements CloudApiClient {
  @override
  Future<List<Map<String, dynamic>>> fetchPendingCommands() async => [];

  @override
  Future<bool> acknowledgeCommand({
    required String commandId,
    required String status,
    Map<String, Object?>? resultPayload,
    String? errorMessage,
  }) async => true;

  @override
  Future<bool> postTelemetry(Map<String, Object?> telemetryData) async => true;

  @override
  Future<bool> testConnection() async => true;

  @override
  Future<Map<String, dynamic>> pairDevice(String pairingKey) async => {
    'status': 'success',
    'accessToken': 'token_pair_123',
  };

  @override
  Future<Map<String, dynamic>> login(String email, String password) async => {
    'status': 'success',
    'accessToken': 'token_login_123',
  };

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String organizationName,
  }) async => {'status': 'success', 'accessToken': 'token_reg_123'};

  @override
  Future<Response<Map<String, dynamic>>> getJson(String path) {
    throw UnimplementedError();
  }

  @override
  Future<Response<Map<String, dynamic>>> postJson(
    String path, {
    Map<String, Object?> data = const {},
    String? idempotencyKey,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  late FakeCloudSettingsService fakeSettingsService;
  late FakeSyncRepository fakeSyncRepository;
  late FakeApiClient fakeApiClient;
  late CloudSyncService cloudSyncService;

  setUp(() {
    fakeSettingsService = FakeCloudSettingsService();
    fakeSyncRepository = FakeSyncRepository();
    fakeApiClient = FakeApiClient();
    cloudSyncService = CloudSyncService(
      repository: fakeSyncRepository,
      apiClient: fakeApiClient,
    );
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith(
          (ref) async => const AppSettingsSnapshot(
            themePreference: AppThemePreference.system,
            languageCode: 'en',
            currencyCode: 'NGN',
            notificationsEnabled: true,
            businessName: 'WireSpot Test',
            businessEmail: 'test@wirespot.app',
            businessPhone: '',
            businessWebsite: '',
            businessLogoPath: '',
          ),
        ),
        cloudControllerProvider.overrideWith((ref) {
          return CloudController(
            settingsService: fakeSettingsService,
            syncRepository: fakeSyncRepository,
            syncService: cloudSyncService,
            apiClient: fakeApiClient,
          );
        }),
      ],
      child: const MaterialApp(home: CloudSettingsPage()),
    );
  }

  testWidgets('renders CloudSettingsPage cards properly', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Cloud Sync'), findsOneWidget);
    expect(find.text('Cloud connection'), findsOneWidget);
    expect(find.text('Cloud session'), findsOneWidget);
    expect(find.text('Test connection'), findsOneWidget);
  });
}
