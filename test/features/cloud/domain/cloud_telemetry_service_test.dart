import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/storage/router_credentials.dart';
import 'package:wirespot/features/cloud/data/cloud_api_client.dart';
import 'package:wirespot/features/cloud/domain/services/cloud_telemetry_service.dart';
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

void main() {
  test(
    'CloudTelemetryService collects metrics and posts telemetry frame',
    () async {
      final apiClient = _FakeCloudApiClient();
      final routerRepo = _FakeRouterRepository();
      final hotspotService = _FakeHotspotService();

      final service = CloudTelemetryService(
        apiClient: apiClient,
        routerRepository: routerRepo,
        hotspotService: hotspotService,
      );

      final count = await service.collectAndPostTelemetry();

      expect(count, 1);
      expect(apiClient.postedTelemetry.length, 1);
      expect(apiClient.postedTelemetry.first['routerId'], 'router-1');
      expect(apiClient.postedTelemetry.first['activeHotspotUsersCount'], 1);
    },
  );
}

class _FakeCloudApiClient implements CloudApiClient {
  @override
  Future<bool> uploadCloudBackup(Map<String, Object?> payloadJson) async =>
      true;
  @override
  Future<Map<String, dynamic>?> fetchLatestCloudBackup() async => null;
  final postedTelemetry = <Map<String, Object?>>[];

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
  Future<bool> postTelemetry(Map<String, Object?> telemetryData) async {
    postedTelemetry.add(telemetryData);
    return true;
  }

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

class _FakeHotspotService implements HotspotService {
  @override
  Future<List<HotspotActiveSessionEntity>> getActiveSessions(
    RouterEntity router,
  ) async => [
    const HotspotActiveSessionEntity(
      id: 'sess-1',
      user: 'user1',
      address: '192.168.88.10',
      macAddress: 'AA:BB:CC:DD:EE:FF',
      uptime: '10m',
      bytesIn: 1000,
      bytesOut: 500,
    ),
  ];

  @override
  Future<void> disconnectSession(RouterEntity router, String sessionId) async {}

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
