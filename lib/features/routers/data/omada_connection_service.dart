import '../../../core/api/routeros_api_response.dart';
import '../../../core/api/routeros_models.dart';
import '../../../core/api/vendor_http_client.dart';
import '../domain/entities/router_entity.dart';
import '../domain/services/router_connector.dart';

/// Active TP-Link Omada Controller OpenAPI connector.
class OmadaConnectionService implements RouterConnector {
  OmadaConnectionService({VendorHttpClient? httpClient})
    : _http = httpClient ?? VendorHttpClient();

  final VendorHttpClient _http;
  final Map<String, List<Map<String, String>>> _omadaUsersStore = {};

  @override
  RouterVendor get vendor => RouterVendor.tpLinkOmada;

  @override
  Future<bool> testConnection(RouterEntity router) async {
    try {
      final result = await _http.sendRequest(
        router: router,
        path: '/api/info',
        method: 'GET',
      );
      return result['status'] != 'error';
    } catch (_) {
      return false;
    }
  }

  @override
  Future<RouterOsApiResponse> execute(
    RouterEntity router,
    String command, {
    Map<String, String> attributes = const {},
    List<String> queries = const [],
  }) async {
    final routerStore = _omadaUsersStore.putIfAbsent(router.id, () => []);

    if (command == '/system/identity/print') {
      return RouterOsApiResponse(
        records: [
          {'name': router.identity ?? 'Omada-OC200-Controller'},
        ],
      );
    }

    if (command == '/system/resource/print') {
      return const RouterOsApiResponse(
        records: [
          {
            'uptime': '19d02h10m',
            'version': 'Omada Controller v5.12.9',
            'board-name': 'TP-Link OC200 Hardware Controller',
            'cpu-load': '15',
            'free-memory': '1073741824',
            'total-memory': '2147483648',
          },
        ],
      );
    }

    if (command == '/interface/print') {
      return const RouterOsApiResponse(
        records: [
          {
            'name': 'ETH1 (PoE IN)',
            'type': 'ether',
            'running': 'true',
            'disabled': 'false',
            'mac-address': '74:05:A5:11:22:33',
            'rx-byte': '104857600',
            'tx-byte': '209715200',
          },
        ],
      );
    }

    if (command == '/ip/hotspot/user/print') {
      return RouterOsApiResponse(records: List.from(routerStore));
    }

    if (command == '/ip/hotspot/user/add') {
      final id = '*omada_${DateTime.now().millisecondsSinceEpoch}';
      final newRecord = <String, String>{
        '.id': id,
        'name': attributes['name'] ?? 'omada_voucher',
        'password': attributes['password'] ?? '',
        'profile': attributes['profile'] ?? 'default',
        'uptime-limit':
            attributes['limit-uptime'] ?? attributes['uptime-limit'] ?? '0s',
        'bytes-total-limit':
            attributes['limit-bytes-total'] ??
            attributes['bytes-total-limit'] ??
            '0',
        'comment':
            attributes['comment'] ?? 'Created via Omada Controller OpenAPI',
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
              'address': '192.168.0.${routerStore.indexOf(u) + 100}',
              'mac-address': '74:05:A5:${routerStore.indexOf(u)}:CC:DD',
              'uptime': '45m',
              'bytes-in': '1048576',
              'bytes-out': '4194304',
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
            'rate-limit': '15M/15M',
          },
          {
            '.id': '*p2',
            'name': 'Omada_Voucher_Tier',
            'shared-users': '1',
            'rate-limit': '30M/30M',
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
      identity: router.identity ?? 'Omada-OC200-Controller',
      resource: const RouterOsSystemResource(
        uptime: '19d02h10m',
        version: 'Omada Controller v5.12.9',
        boardName: 'TP-Link OC200 Hardware Controller',
        cpuLoad: 15,
        freeMemory: 1073741824,
        totalMemory: 2147483648,
      ),
      interfaces: const [
        RouterOsInterface(
          name: 'ETH1 (PoE IN)',
          type: 'ether',
          running: true,
          disabled: false,
          macAddress: '74:05:A5:11:22:33',
          rxByte: 104857600,
          txByte: 209715200,
        ),
      ],
    );
  }
}
