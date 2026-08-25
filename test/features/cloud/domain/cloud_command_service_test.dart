import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/api/routeros_api_response.dart';
import 'package:wirespot/core/api/routeros_models.dart';
import 'package:wirespot/core/storage/router_credentials.dart';
import 'package:wirespot/features/routers/domain/entities/router_entity.dart'
    show RouterEntity;
import 'package:wirespot/features/cloud/data/cloud_api_client.dart';
import 'package:wirespot/features/cloud/domain/entities/cloud_sync_operation.dart';
import 'package:wirespot/features/cloud/domain/repositories/cloud_sync_repository.dart';
import 'package:wirespot/features/cloud/domain/services/cloud_command_service.dart';
import 'package:wirespot/features/cloud/domain/services/cloud_sync_service.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_active_session_entity.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_cookie_entity.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_ip_binding_entity.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_ip_binding_input.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_profile_input.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_queue_entity.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_setup_inspection.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_setup_input.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_user_entity.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_user_input.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_user_profile_entity.dart';
import 'package:wirespot/features/hotspot/domain/services/hotspot_service.dart';
import 'package:wirespot/features/routers/domain/entities/router_entity.dart';
import 'package:wirespot/features/routers/domain/entities/router_group_entity.dart';
import 'package:wirespot/features/routers/domain/repositories/router_repository.dart';
import 'package:wirespot/features/routers/domain/services/router_connection_service.dart';

void main() {
  test('CloudCommandService processes pending remote reboot command', () async {
    final apiClient = _FakeCloudApiClient(
      pendingCommands: [
        {
          'id': 'cmd-1',
          'type': 'remote_reboot',
          'targetResourceId': 'router-1',
          'status': 'pending',
          'createdAt': '2026-08-24T10:00:00.000Z',
        },
      ],
    );
    final routerRepo = _FakeRouterRepository();
    final routerConnService = _FakeRouterConnectionService();
    final hotspotService = _FakeHotspotService();
    final syncRepo = _FakeCloudSyncRepository();
    final cloudSyncService = CloudSyncService(
      repository: syncRepo,
      apiClient: apiClient,
    );

    final service = CloudCommandService(
      apiClient: apiClient,
      routerRepository: routerRepo,
      routerConnectionService: routerConnService,
      hotspotService: hotspotService,
      cloudSyncService: cloudSyncService,
    );

    final results = await service.processPendingCommands();

    expect(results.length, 1);
    expect(results.first.commandId, 'cmd-1');
    expect(results.first.success, true);
    expect(routerConnService.executedCommands, ['/system/reboot']);
    expect(apiClient.acknowledgedCommands.single['commandId'], 'cmd-1');
    expect(apiClient.acknowledgedCommands.single['status'], 'completed');
  });

  test('CloudCommandService processes kick session command', () async {
    final apiClient = _FakeCloudApiClient(
      pendingCommands: [
        {
          'id': 'cmd-2',
          'type': 'kick_session',
          'targetResourceId': 'router-1',
          'params': {'mac': 'BC:D1:D3:4A:89:12'},
          'status': 'pending',
          'createdAt': '2026-08-24T10:00:00.000Z',
        },
      ],
    );
    final routerRepo = _FakeRouterRepository();
    final routerConnService = _FakeRouterConnectionService();
    final hotspotService = _FakeHotspotService();
    final syncRepo = _FakeCloudSyncRepository();
    final cloudSyncService = CloudSyncService(
      repository: syncRepo,
      apiClient: apiClient,
    );

    final service = CloudCommandService(
      apiClient: apiClient,
      routerRepository: routerRepo,
      routerConnectionService: routerConnService,
      hotspotService: hotspotService,
      cloudSyncService: cloudSyncService,
    );

    final results = await service.processPendingCommands();

    expect(results.length, 1);
    expect(results.first.success, true);
    expect(hotspotService.removedSessions, ['router-1:BC:D1:D3:4A:89:12']);
  });
}

class _FakeCloudApiClient implements CloudApiClient {
  _FakeCloudApiClient({this.pendingCommands = const []});

  final List<Map<String, dynamic>> pendingCommands;
  final acknowledgedCommands = <Map<String, dynamic>>[];
  final postedTelemetry = <Map<String, Object?>>[];

  @override
  Future<List<Map<String, dynamic>>> fetchPendingCommands() async =>
      pendingCommands;

  @override
  Future<bool> acknowledgeCommand({
    required String commandId,
    required String status,
    Map<String, Object?>? resultPayload,
    String? errorMessage,
  }) async {
    acknowledgedCommands.add({
      'commandId': commandId,
      'status': status,
      'resultPayload': resultPayload,
      'errorMessage': errorMessage,
    });
    return true;
  }

  @override
  Future<bool> postTelemetry(Map<String, Object?> telemetryData) async {
    postedTelemetry.add(telemetryData);
    return true;
  }

  @override
  Future<bool> testConnection() async => true;

  @override
  Future<Response<Map<String, dynamic>>> getJson(String path) async {
    return Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {'status': 'ok'},
    );
  }

  @override
  Future<Response<Map<String, dynamic>>> postJson(
    String path, {
    Map<String, Object?> data = const {},
    String? idempotencyKey,
  }) async {
    return Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {'status': 'ok'},
    );
  }
}

class _FakeRouterRepository implements RouterRepository {
  @override
  Stream<List<RouterEntity>> watchRouters() => Stream.value(const [
    RouterEntity(
      id: 'router-1',
      name: 'Main Router',
      host: '192.168.88.1',
      username: 'admin',
    ),
  ]);

  @override
  Future<List<RouterEntity>> getRouters() async => [
    const RouterEntity(
      id: 'router-1',
      name: 'Main Router',
      host: '192.168.88.1',
      username: 'admin',
    ),
  ];

  @override
  Future<RouterEntity?> getRouter(String id) async => const RouterEntity(
    id: 'router-1',
    name: 'Main Router',
    host: '192.168.88.1',
    username: 'admin',
  );

  @override
  Future<void> deleteRouter(String id) async {}

  @override
  Future<List<RouterGroupEntity>> getGroups() async => const [];

  @override
  Future<void> saveGroup(RouterGroupEntity group) async {}

  @override
  Future<void> saveRouter(
    RouterEntity router, {
    RouterCredentials? credentials,
  }) async {}
}

class _FakeRouterConnectionService implements RouterConnectionService {
  final executedCommands = <String>[];

  @override
  Future<bool> testConnection(RouterEntity router) async => true;

  @override
  Future<RouterOsApiResponse> execute(
    RouterEntity router,
    String command, {
    Map<String, String>? attributes,
    List<String>? queries,
  }) async {
    executedCommands.add(command);
    return const RouterOsApiResponse(records: []);
  }

  @override
  Stream<Map<String, String>> stream(
    RouterEntity router,
    String command, {
    Map<String, String>? attributes,
    List<String>? queries,
  }) => const Stream.empty();

  @override
  Future<RouterOsRouterSnapshot> getSnapshot(RouterEntity router) async =>
      RouterOsRouterSnapshot(
        identity: 'MikroTik',
        resource: const RouterOsSystemResource(
          uptime: '1d0h0m0s',
          version: '7.12',
          boardName: 'RB3011',
          cpuLoad: 14,
          freeMemory: 134217728,
          totalMemory: 268435456,
        ),
        interfaces: const [],
      );
}

class _FakeHotspotService implements HotspotService {
  final removedSessions = <String>[];

  @override
  Future<void> disconnectSession(RouterEntity router, String sessionId) async {
    removedSessions.add('${router.id}:$sessionId');
  }

  @override
  Future<List<HotspotActiveSessionEntity>> getActiveSessions(
    RouterEntity router,
  ) async => const [];

  @override
  Future<void> createIpBinding(
    RouterEntity router,
    HotspotIpBindingInput input,
  ) async {}

  @override
  Future<void> createProfile(
    RouterEntity router,
    HotspotProfileInput input,
  ) async {}

  @override
  Future<void> createUser(RouterEntity router, HotspotUserInput input) async {}

  @override
  Future<void> deleteCookie(RouterEntity router, String cookieId) async {}

  @override
  Future<void> deleteIpBinding(RouterEntity router, String bindingId) async {}

  @override
  Future<void> deleteProfile(RouterEntity router, String profileId) async {}

  @override
  Future<void> deleteUser(RouterEntity router, String userId) async {}

  @override
  Future<List<HotspotCookieEntity>> getCookies(RouterEntity router) async =>
      const [];

  @override
  Future<List<HotspotIpBindingEntity>> getIpBindings(
    RouterEntity router,
  ) async => const [];

  @override
  Future<List<HotspotUserProfileEntity>> getProfiles(
    RouterEntity router,
  ) async => const [];

  @override
  Future<List<HotspotQueueEntity>> getQueues(RouterEntity router) async =>
      const [];

  @override
  Future<List<HotspotUserEntity>> getUsers(RouterEntity router) async =>
      const [];

  @override
  Future<HotspotSetupInspection> inspectSetup(
    RouterEntity router,
    HotspotSetupInput input,
  ) async =>
      const HotspotSetupInspection(serverExists: true, profileExists: true);

  @override
  Future<void> resetUserCounters(RouterEntity router, String userId) async {}

  @override
  Future<void> setupHotspot(
    RouterEntity router,
    HotspotSetupInput input,
  ) async {}

  @override
  Future<void> updateIpBinding(
    RouterEntity router,
    String bindingId,
    HotspotIpBindingInput input,
  ) async {}

  @override
  Future<void> updateProfile(
    RouterEntity router,
    String profileId,
    HotspotProfileInput input,
  ) async {}

  @override
  Future<void> updateUser(
    RouterEntity router,
    String userId,
    HotspotUserInput input,
  ) async {}
}

class _FakeCloudSyncRepository implements CloudSyncRepository {
  final operations = <CloudSyncOperation>[];

  @override
  Future<void> enqueue(CloudSyncOperation operation) async {
    operations.add(operation);
  }

  @override
  Future<List<CloudSyncOperation>> pendingOperations() async => operations;

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
