import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/storage/router_credentials.dart';
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
import 'package:wirespot/features/reports/domain/entities/sale_entity.dart';
import 'package:wirespot/features/reports/domain/repositories/report_repository.dart';
import 'package:wirespot/features/reports/domain/services/report_summary_service.dart';
import 'package:wirespot/features/routers/domain/entities/router_entity.dart';
import 'package:wirespot/features/routers/domain/entities/router_group_entity.dart';
import 'package:wirespot/features/routers/domain/repositories/router_repository.dart';
import 'package:wirespot/features/scheduler/domain/entities/scheduled_task.dart';
import 'package:wirespot/features/scheduler/domain/services/scheduler_execution_service.dart';
import 'package:wirespot/features/scheduler/domain/services/scheduler_settings_service.dart';
import 'package:wirespot/features/settings/domain/entities/printer_config_entity.dart';
import 'package:wirespot/features/settings/domain/repositories/settings_repository.dart';
import 'package:wirespot/features/settings/domain/services/backup_service.dart';
import 'package:wirespot/features/cloud/data/cloud_api_client.dart';
import 'package:wirespot/features/cloud/domain/entities/cloud_sync_operation.dart';
import 'package:wirespot/features/cloud/domain/repositories/cloud_sync_repository.dart';
import 'package:wirespot/features/cloud/domain/services/cloud_sync_service.dart';
import 'package:wirespot/features/voucher/domain/entities/hotspot_profile_entity.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_entity.dart';
import 'package:wirespot/features/voucher/domain/repositories/voucher_repository.dart';

void main() {
  test('runs due enabled scheduler tasks and records status', () async {
    final settings = _FakeSettingsRepository()
      ..values['scheduler.dailySalesSummary.enabled'] = 'true'
      ..values['scheduler.dailySalesSummary.intervalMinutes'] = '1440'
      ..values['scheduler.databaseBackup.enabled'] = 'true'
      ..values['scheduler.databaseBackup.intervalMinutes'] = '1440';
    final service = _service(settings);

    final results = await service.runDueTasks(now: DateTime(2026, 7, 13, 12));

    expect(
      results.map((result) => result.type),
      containsAll([
        ScheduledTaskType.dailySalesSummary,
        ScheduledTaskType.databaseBackup,
      ]),
    );
    expect(
      settings.values['scheduler.dailySalesSummary.lastRunStatus'],
      contains('Daily sales: 1 transactions'),
    );
    expect(
      settings.values['scheduler.databaseBackup.lastRunStatus'],
      contains('Backup snapshot ready'),
    );
  });

  test('skips enabled tasks that are not due yet', () async {
    final settings = _FakeSettingsRepository()
      ..values['scheduler.dailySalesSummary.enabled'] = 'true'
      ..values['scheduler.dailySalesSummary.intervalMinutes'] = '60'
      ..values['scheduler.dailySalesSummary.lastRunAt'] = DateTime(
        2026,
        7,
        13,
        11,
        30,
      ).toIso8601String();
    final service = _service(settings);

    final results = await service.runDueTasks(now: DateTime(2026, 7, 13, 12));

    expect(results, isEmpty);
  });

  test('refreshes active sessions across enabled routers', () async {
    final settings = _FakeSettingsRepository()
      ..values['scheduler.activeSessionRefresh.enabled'] = 'true'
      ..values['scheduler.activeSessionRefresh.intervalMinutes'] = '5';
    final hotspot = _FakeHotspotService()
      ..sessions['router-1'] = const [
        HotspotActiveSessionEntity(id: '*1', user: 'alpha'),
        HotspotActiveSessionEntity(id: '*2', user: 'beta'),
      ];
    final service = _service(settings, hotspotService: hotspot);

    final results = await service.runDueTasks(now: DateTime(2026, 7, 13, 12));

    expect(results.single.type, ScheduledTaskType.activeSessionRefresh);
    expect(results.single.message, contains('2 active sessions found'));
    expect(hotspot.sessionLoads, 1);
  });

  test('disconnects active sessions with zero time left', () async {
    final settings = _FakeSettingsRepository()
      ..values['scheduler.expiredUserCleanup.enabled'] = 'true'
      ..values['scheduler.expiredUserCleanup.intervalMinutes'] = '60';
    final hotspot = _FakeHotspotService()
      ..sessions['router-1'] = const [
        HotspotActiveSessionEntity(
          id: '*expired',
          user: 'alpha',
          sessionTimeLeft: '0s',
        ),
        HotspotActiveSessionEntity(
          id: '*active',
          user: 'beta',
          sessionTimeLeft: '12m',
        ),
      ];
    final service = _service(settings, hotspotService: hotspot);

    final results = await service.runDueTasks(now: DateTime(2026, 7, 13, 12));

    expect(results.single.type, ScheduledTaskType.expiredUserCleanup);
    expect(results.single.message, contains('1 expired sessions disconnected'));
    expect(hotspot.disconnectedSessions, ['router-1:*expired']);
  });

  test('cleans up expired unused local vouchers', () async {
    final settings = _FakeSettingsRepository()
      ..values['scheduler.voucherCleanup.enabled'] = 'true'
      ..values['scheduler.voucherCleanup.intervalMinutes'] = '1440';
    final voucherRepository = _FakeVoucherRepository()
      ..vouchers.addAll([
        VoucherEntity(
          id: 'expired-unused',
          routerId: 'router-1',
          username: 'old-pin',
          priceMinor: 10000,
          currency: 'NGN',
          validityMinutes: 60,
          generatedAt: DateTime(2026, 7, 13, 10),
        ),
        VoucherEntity(
          id: 'expired-printed',
          routerId: 'router-1',
          username: 'printed-pin',
          priceMinor: 10000,
          currency: 'NGN',
          validityMinutes: 60,
          generatedAt: DateTime(2026, 7, 13, 10),
          printedAt: DateTime(2026, 7, 13, 10, 5),
        ),
        VoucherEntity(
          id: 'still-valid',
          routerId: 'router-1',
          username: 'new-pin',
          priceMinor: 10000,
          currency: 'NGN',
          validityMinutes: 60,
          generatedAt: DateTime(2026, 7, 13, 11, 30),
        ),
      ]);
    final service = _service(settings, voucherRepository: voucherRepository);

    final results = await service.runDueTasks(now: DateTime(2026, 7, 13, 12));

    expect(results.single.type, ScheduledTaskType.voucherCleanup);
    expect(results.single.message, contains('1 expired unused voucher'));
    expect(voucherRepository.deletedVoucherIds, ['expired-unused']);
  });

  test('triggers background cloud sync when cloudSync task is due', () async {
    final settings = _FakeSettingsRepository()
      ..values['scheduler.cloudSync.enabled'] = 'true'
      ..values['scheduler.cloudSync.intervalMinutes'] = '15';
    final fakeCloudSyncRepo = _FakeCloudSyncRepository();
    final fakeApiClient = _FakeCloudApiClient();
    final cloudSyncService = CloudSyncService(
      repository: fakeCloudSyncRepo,
      apiClient: fakeApiClient,
    );
    await cloudSyncService.queueUpsert(
      resourceType: 'router',
      resourceId: 'r-1',
      payload: {'name': 'Router 1'},
    );
    final service = _service(settings, cloudSyncService: cloudSyncService);

    final results = await service.runDueTasks(now: DateTime(2026, 7, 13, 12));

    expect(results.single.type, ScheduledTaskType.cloudSync);
    expect(
      results.single.message,
      contains('Cloud sync synchronized 1 pending operation(s)'),
    );
  });
}

SchedulerExecutionService _service(
  _FakeSettingsRepository settings, {
  _FakeHotspotService? hotspotService,
  _FakeVoucherRepository? voucherRepository,
  CloudSyncService? cloudSyncService,
}) {
  return SchedulerExecutionService(
    settingsService: SchedulerSettingsService(settings),
    backupService: BackupService(settings),
    reportSummaryService: ReportSummaryService(_FakeReportRepository()),
    routerRepository: _FakeRouterRepository(),
    hotspotService: hotspotService ?? _FakeHotspotService(),
    voucherRepository: voucherRepository ?? _FakeVoucherRepository(),
    cloudSyncService: cloudSyncService,
  );
}

class _FakeSettingsRepository implements SettingsRepository {
  final values = <String, String>{};

  @override
  Future<String?> readSetting(String key) async => values[key];

  @override
  Future<void> writeSetting(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> deletePrinter(String id) {
    return Future.value();
  }

  @override
  Future<List<PrinterConfigEntity>> getPrinters() async {
    return const [
      PrinterConfigEntity(
        id: 'printer-1',
        name: 'Field Printer',
        address: 'AA:BB:CC:DD:EE:FF',
      ),
    ];
  }

  @override
  Future<void> savePrinter(PrinterConfigEntity printer) {
    return Future.value();
  }
}

class _FakeReportRepository implements ReportRepository {
  @override
  Future<List<SaleEntity>> getSales({
    String? routerId,
    DateTime? from,
    DateTime? to,
  }) async {
    return [
      SaleEntity(
        id: 'sale-1',
        routerId: 'router-1',
        amountMinor: 50000,
        currency: 'NGN',
        soldAt: DateTime(2026, 7, 13, 10),
      ),
    ];
  }

  @override
  Future<void> recordSale(SaleEntity sale) {
    return Future.value();
  }
}

class _FakeRouterRepository implements RouterRepository {
  final routers = const [
    RouterEntity(
      id: 'router-1',
      name: 'Field Router',
      host: '172.16.1.1',
      username: 'admin',
      requireVpn: false,
      remoteAccessMode: RouterRemoteAccessMode.localLan,
    ),
  ];

  @override
  Future<void> deleteRouter(String id) async {}

  @override
  Future<List<RouterGroupEntity>> getGroups() async => const [];

  @override
  Future<RouterEntity?> getRouter(String id) async {
    for (final router in routers) {
      if (router.id == id) {
        return router;
      }
    }
    return null;
  }

  @override
  Future<List<RouterEntity>> getRouters() async => routers;

  @override
  Future<void> saveGroup(RouterGroupEntity group) async {}

  @override
  Future<void> saveRouter(
    RouterEntity router, {
    RouterCredentials? credentials,
  }) async {}

  @override
  Stream<List<RouterEntity>> watchRouters() => Stream.value(routers);
}

class _FakeHotspotService implements HotspotService {
  final sessions = <String, List<HotspotActiveSessionEntity>>{};
  final disconnectedSessions = <String>[];
  var sessionLoads = 0;

  @override
  Future<HotspotSetupInspection> inspectSetup(
    RouterEntity router,
    HotspotSetupInput input,
  ) async =>
      const HotspotSetupInspection(serverExists: false, profileExists: false);

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
  Future<void> disconnectSession(RouterEntity router, String sessionId) async {
    disconnectedSessions.add('${router.id}:$sessionId');
  }

  @override
  Future<List<HotspotActiveSessionEntity>> getActiveSessions(
    RouterEntity router,
  ) async {
    sessionLoads += 1;
    return sessions[router.id] ?? const [];
  }

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

class _FakeVoucherRepository implements VoucherRepository {
  final vouchers = <VoucherEntity>[];
  final deletedVoucherIds = <String>[];

  @override
  Future<void> deleteVouchers(List<String> voucherIds) async {
    deletedVoucherIds.addAll(voucherIds);
    vouchers.removeWhere((voucher) => voucherIds.contains(voucher.id));
  }

  @override
  Future<List<HotspotProfileEntity>> getProfiles(String routerId) async =>
      const [];

  @override
  Future<List<VoucherEntity>> getVoucherHistory({
    String? routerId,
    DateTime? from,
    DateTime? to,
  }) async => vouchers
      .where((voucher) => routerId == null || voucher.routerId == routerId)
      .where((voucher) => from == null || !voucher.generatedAt.isBefore(from))
      .where((voucher) => to == null || !voucher.generatedAt.isAfter(to))
      .toList();

  @override
  Future<void> saveProfile(HotspotProfileEntity profile) async {}

  @override
  Future<void> saveVoucher(VoucherEntity voucher) async {
    vouchers.add(voucher);
  }
}

class _FakeCloudSyncRepository implements CloudSyncRepository {
  final operations = <CloudSyncOperation>[];

  @override
  Future<void> enqueue(CloudSyncOperation operation) async {
    operations.add(operation);
  }

  @override
  Future<List<CloudSyncOperation>> pendingOperations() async {
    return operations
        .where(
          (op) =>
              op.status == CloudSyncStatus.pending ||
              op.status == CloudSyncStatus.failed,
        )
        .toList();
  }

  @override
  Future<void> markSyncing(String id) async {
    final index = operations.indexWhere((op) => op.id == id);
    if (index != -1) {
      final op = operations[index];
      operations[index] = CloudSyncOperation(
        id: op.id,
        operation: op.operation,
        resourceType: op.resourceType,
        resourceId: op.resourceId,
        payload: op.payload,
        idempotencyKey: op.idempotencyKey,
        status: CloudSyncStatus.syncing,
        createdAt: op.createdAt,
        updatedAt: DateTime.now(),
        attemptCount: op.attemptCount + 1,
        lastError: op.lastError,
      );
    }
  }

  @override
  Future<void> markCompleted(String id) async {
    final index = operations.indexWhere((op) => op.id == id);
    if (index != -1) {
      final op = operations[index];
      operations[index] = CloudSyncOperation(
        id: op.id,
        operation: op.operation,
        resourceType: op.resourceType,
        resourceId: op.resourceId,
        payload: op.payload,
        idempotencyKey: op.idempotencyKey,
        status: CloudSyncStatus.completed,
        createdAt: op.createdAt,
        updatedAt: DateTime.now(),
        attemptCount: op.attemptCount,
        lastError: null,
      );
    }
  }

  @override
  Future<void> markFailed(String id, String error) async {
    final index = operations.indexWhere((op) => op.id == id);
    if (index != -1) {
      final op = operations[index];
      operations[index] = CloudSyncOperation(
        id: op.id,
        operation: op.operation,
        resourceType: op.resourceType,
        resourceId: op.resourceId,
        payload: op.payload,
        idempotencyKey: op.idempotencyKey,
        status: CloudSyncStatus.failed,
        createdAt: op.createdAt,
        updatedAt: DateTime.now(),
        attemptCount: op.attemptCount,
        lastError: error,
      );
    }
  }

  @override
  Future<int> clearCompleted() async {
    final before = operations.length;
    operations.removeWhere((op) => op.status == CloudSyncStatus.completed);
    return before - operations.length;
  }

  @override
  Future<int> retryFailed() async {
    var count = 0;
    for (var i = 0; i < operations.length; i++) {
      if (operations[i].status == CloudSyncStatus.failed) {
        final op = operations[i];
        operations[i] = CloudSyncOperation(
          id: op.id,
          operation: op.operation,
          resourceType: op.resourceType,
          resourceId: op.resourceId,
          payload: op.payload,
          idempotencyKey: op.idempotencyKey,
          status: CloudSyncStatus.pending,
          createdAt: op.createdAt,
          updatedAt: DateTime.now(),
          attemptCount: op.attemptCount,
          lastError: op.lastError,
        );
        count++;
      }
    }
    return count;
  }
}

class _FakeCloudApiClient implements CloudApiClient {
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
  }) async => {
    'status': 'success',
    'accessToken': 'token_reg_123',
  };

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
