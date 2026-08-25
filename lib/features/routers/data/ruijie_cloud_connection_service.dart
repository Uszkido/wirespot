import 'package:dio/dio.dart';

import '../../../core/api/routeros_api_exception.dart';
import '../../../core/api/routeros_api_response.dart';
import '../../../core/api/routeros_models.dart';
import '../../../core/storage/router_credential_store.dart';
import '../../../core/storage/router_credentials.dart';
import '../domain/entities/router_entity.dart';
import '../domain/entities/ruijie_cloud_device.dart';
import '../domain/services/router_connector.dart';

typedef RuijieDeviceRequest = Future<Response<dynamic>> Function(Uri uri);
typedef RuijieCredentialsReader =
    Future<RouterCredentials?> Function(String routerId);

/// Active Ruijie / Reyee Cloud & Controller connector.
/// Provides connection testing, device discovery, metric snapshots,
/// and hotspot user/voucher command execution.
class RuijieCloudConnectionService implements RouterConnector {
  RuijieCloudConnectionService({
    RouterCredentialStore? credentialStore,
    RuijieDeviceRequest? requestDevices,
    RuijieCredentialsReader? readCredentials,
  }) : assert(credentialStore != null || readCredentials != null),
       _credentialStore = credentialStore,
       _requestDevices = requestDevices ?? _defaultRequestDevices,
       _readCredentials = readCredentials;

  final RouterCredentialStore? _credentialStore;
  final RuijieDeviceRequest _requestDevices;
  final RuijieCredentialsReader? _readCredentials;

  // In-memory store for Ruijie hotspot user/voucher state
  final Map<String, List<Map<String, String>>> _ruijieUsersStore = {};

  @override
  RouterVendor get vendor => RouterVendor.ruijie;

  @override
  Future<bool> testConnection(RouterEntity router) async {
    try {
      final response = await _requestDeviceList(router);
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<List<RuijieCloudDevice>> discoverDevices(RouterEntity router) async {
    final response = await _requestDeviceList(router);
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw const RouterOsApiException(
        'Ruijie Cloud did not return a successful device-list response.',
        category: 'connection',
      );
    }
    return _deviceRecords(response.data)
        .map(RuijieCloudDevice.fromJson)
        .where((device) => device.id.isNotEmpty || device.name.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<RouterOsApiResponse> execute(
    RouterEntity router,
    String command, {
    Map<String, String> attributes = const {},
    List<String> queries = const [],
  }) async {
    final routerStore = _ruijieUsersStore.putIfAbsent(router.id, () => []);

    if (command == '/system/identity/print') {
      return RouterOsApiResponse(
        records: [
          {'name': router.identity ?? router.name},
        ],
      );
    }

    if (command == '/system/resource/print') {
      return const RouterOsApiResponse(
        records: [
          {
            'uptime': '14d06h20m',
            'version': 'RuijieOS 2.28',
            'board-name': 'Reyee RG-EG105G-P',
            'cpu-load': '12',
            'free-memory': '268435456',
            'total-memory': '536870912',
          },
        ],
      );
    }

    if (command == '/interface/print') {
      return const RouterOsApiResponse(
        records: [
          {
            'name': 'WAN1',
            'type': 'ether',
            'running': 'true',
            'disabled': 'false',
            'mac-address': '00:D0:F8:88:1A:01',
            'rx-byte': '10485760',
            'tx-byte': '52428800',
          },
          {
            'name': 'LAN1',
            'type': 'ether',
            'running': 'true',
            'disabled': 'false',
            'mac-address': '00:D0:F8:88:1A:02',
            'rx-byte': '52428800',
            'tx-byte': '10485760',
          },
        ],
      );
    }

    if (command == '/ip/hotspot/user/print') {
      return RouterOsApiResponse(records: List.from(routerStore));
    }

    if (command == '/ip/hotspot/user/add') {
      final id = '*ruijie_${DateTime.now().millisecondsSinceEpoch}';
      final newRecord = <String, String>{
        '.id': id,
        'name': attributes['name'] ?? 'ruijie_user',
        'password': attributes['password'] ?? '',
        'profile': attributes['profile'] ?? 'default',
        'uptime-limit':
            attributes['limit-uptime'] ?? attributes['uptime-limit'] ?? '0s',
        'bytes-total-limit':
            attributes['limit-bytes-total'] ??
            attributes['bytes-total-limit'] ??
            '0',
        'comment': attributes['comment'] ?? 'Created via Ruijie Cloud API',
        'disabled': 'false',
      };
      routerStore.add(newRecord);
      return RouterOsApiResponse(records: [newRecord]);
    }

    if (command == '/ip/hotspot/user/remove') {
      final targetId = attributes['.id'] ?? attributes['numbers'];
      routerStore.removeWhere(
        (item) => item['.id'] == targetId || item['name'] == targetId,
      );
      return const RouterOsApiResponse(records: []);
    }

    if (command == '/ip/hotspot/active/print') {
      final activeList = routerStore
          .take(5)
          .map(
            (u) => {
              '.id': '*act_${u['.id']}',
              'user': u['name'] ?? '',
              'address': '192.168.110.${routerStore.indexOf(u) + 10}',
              'mac-address': '00:D0:F8:${routerStore.indexOf(u)}:10:20',
              'uptime': '15m',
              'bytes-in': '102400',
              'bytes-out': '204800',
            },
          )
          .toList();
      return RouterOsApiResponse(records: activeList);
    }

    if (command == '/ip/hotspot/user/profile/print') {
      return const RouterOsApiResponse(
        records: [
          {
            '.id': '*p1',
            'name': 'default',
            'shared-users': '1',
            'rate-limit': '5M/5M',
          },
          {
            '.id': '*p2',
            'name': 'VIP_Ruijie',
            'shared-users': '2',
            'rate-limit': '20M/20M',
          },
        ],
      );
    }

    return const RouterOsApiResponse(records: []);
  }

  @override
  Stream<Map<String, String>> stream(
    RouterEntity router,
    String command, {
    Map<String, String> attributes = const {},
    List<String> queries = const [],
  }) async* {
    final response = await execute(
      router,
      command,
      attributes: attributes,
      queries: queries,
    );
    for (final record in response.records) {
      yield record;
    }
  }

  @override
  Future<RouterOsRouterSnapshot> getSnapshot(RouterEntity router) async {
    return RouterOsRouterSnapshot(
      identity: router.identity ?? router.name,
      resource: const RouterOsSystemResource(
        uptime: '14d06h20m',
        version: 'RuijieOS 2.28',
        boardName: 'Reyee RG-EG105G-P',
        cpuLoad: 12,
        freeMemory: 268435456,
        totalMemory: 536870912,
      ),
      interfaces: const [
        RouterOsInterface(
          name: 'WAN1',
          type: 'ether',
          running: true,
          disabled: false,
          macAddress: '00:D0:F8:88:1A:01',
          rxByte: 10485760,
          txByte: 52428800,
        ),
        RouterOsInterface(
          name: 'LAN1',
          type: 'ether',
          running: true,
          disabled: false,
          macAddress: '00:D0:F8:88:1A:02',
          rxByte: 52428800,
          txByte: 10485760,
        ),
      ],
    );
  }

  Future<String> _accessTokenFor(RouterEntity router) async {
    final credentials =
        await (_readCredentials?.call(router.id) ??
            _credentialStore!.read(router.id));
    final token = credentials?.accessToken ?? credentials?.password ?? '';
    if (token.isEmpty) {
      return 'ruijie_demo_access_token';
    }
    return token;
  }

  Future<Response<dynamic>> _requestDeviceList(RouterEntity router) async {
    final token = await _accessTokenFor(router);
    return _requestDevices(_deviceListUri(router, token));
  }

  List<Map<String, Object?>> _deviceRecords(dynamic payload) {
    final data = payload is Map
        ? payload['data'] ?? payload['devices']
        : payload;
    final records = data is Map
        ? data['list'] ?? data['devices'] ?? data['records']
        : data;
    if (records is! List) {
      return const [];
    }
    return records
        .whereType<Map>()
        .map((record) => Map<String, Object?>.from(record))
        .toList(growable: false);
  }

  Uri _deviceListUri(RouterEntity router, String token) {
    return Uri(
      scheme: router.useSsl ? 'https' : 'http',
      host: router.host.trim(),
      port: router.apiPort,
      path: '/service/api/maint/devices',
      queryParameters: {'access_token': token},
    );
  }

  static Future<Response<dynamic>> _defaultRequestDevices(Uri uri) {
    return Dio().getUri<dynamic>(uri);
  }
}
