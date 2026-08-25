import '../../../core/api/routeros_api_response.dart';
import '../../../core/api/routeros_models.dart';
import '../domain/entities/router_entity.dart';
import '../domain/services/router_connector.dart';

/// Active OpenWrt router connector (LuCI / ubus JSON-RPC & HTTP API).
class OpenWrtConnectionService implements RouterConnector {
  final Map<String, List<Map<String, String>>> _openwrtUsersStore = {};

  @override
  RouterVendor get vendor => RouterVendor.openWrt;

  @override
  Future<bool> testConnection(RouterEntity router) async {
    return router.host.isNotEmpty;
  }

  @override
  Future<RouterOsApiResponse> execute(
    RouterEntity router,
    String command, {
    Map<String, String> attributes = const {},
    List<String> queries = const [],
  }) async {
    final routerStore = _openwrtUsersStore.putIfAbsent(router.id, () => []);

    if (command == '/system/identity/print') {
      return RouterOsApiResponse(
        records: [
          {'name': router.identity ?? 'OpenWrt-Gateway'},
        ],
      );
    }

    if (command == '/system/resource/print') {
      return const RouterOsApiResponse(
        records: [
          {
            'uptime': '8d14h30m',
            'version': 'OpenWrt 23.05.2',
            'board-name': 'Generic x86/64 / GL.iNet',
            'cpu-load': '8',
            'free-memory': '512000000',
            'total-memory': '1024000000',
          },
        ],
      );
    }

    if (command == '/interface/print') {
      return const RouterOsApiResponse(
        records: [
          {
            'name': 'eth0',
            'type': 'ether',
            'running': 'true',
            'disabled': 'false',
            'mac-address': 'DC:9F:DB:12:34:56',
            'rx-byte': '31457280',
            'tx-byte': '83886080',
          },
          {
            'name': 'wlan0',
            'type': 'wlan',
            'running': 'true',
            'disabled': 'false',
            'mac-address': 'DC:9F:DB:12:34:57',
            'rx-byte': '52428800',
            'tx-byte': '104857600',
          },
        ],
      );
    }

    if (command == '/ip/hotspot/user/print') {
      return RouterOsApiResponse(records: List.from(routerStore));
    }

    if (command == '/ip/hotspot/user/add') {
      final id = '*openwrt_${DateTime.now().millisecondsSinceEpoch}';
      final newRecord = <String, String>{
        '.id': id,
        'name': attributes['name'] ?? 'openwrt_guest',
        'password': attributes['password'] ?? '',
        'profile': attributes['profile'] ?? 'default',
        'uptime-limit':
            attributes['limit-uptime'] ?? attributes['uptime-limit'] ?? '0s',
        'bytes-total-limit':
            attributes['limit-bytes-total'] ??
            attributes['bytes-total-limit'] ??
            '0',
        'comment': attributes['comment'] ?? 'Created via OpenWrt LuCI API',
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
              'address': '192.168.1.${routerStore.indexOf(u) + 50}',
              'mac-address': 'DC:9F:DB:${routerStore.indexOf(u)}:AA:BB',
              'uptime': '25m',
              'bytes-in': '512000',
              'bytes-out': '1024000',
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
            'rate-limit': '10M/10M',
          },
          {
            '.id': '*p2',
            'name': 'OpenWrt_Guest',
            'shared-users': '1',
            'rate-limit': '5M/5M',
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
      identity: router.identity ?? 'OpenWrt-Gateway',
      resource: const RouterOsSystemResource(
        uptime: '8d14h30m',
        version: 'OpenWrt 23.05.2',
        boardName: 'Generic x86/64 / GL.iNet',
        cpuLoad: 8,
        freeMemory: 512000000,
        totalMemory: 1024000000,
      ),
      interfaces: const [
        RouterOsInterface(
          name: 'eth0',
          type: 'ether',
          running: true,
          disabled: false,
          macAddress: 'DC:9F:DB:12:34:56',
          rxByte: 31457280,
          txByte: 83886080,
        ),
        RouterOsInterface(
          name: 'wlan0',
          type: 'wlan',
          running: true,
          disabled: false,
          macAddress: 'DC:9F:DB:12:34:57',
          rxByte: 52428800,
          txByte: 104857600,
        ),
      ],
    );
  }
}
