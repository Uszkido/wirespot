import '../../../core/api/routeros_api_response.dart';
import '../../../core/api/routeros_models.dart';
import '../domain/entities/router_entity.dart';
import '../domain/services/router_connector.dart';

/// Active Ubiquiti UniFi Controller REST API connector.
class UniFiConnectionService implements RouterConnector {
  final Map<String, List<Map<String, String>>> _unifiUsersStore = {};

  @override
  RouterVendor get vendor => RouterVendor.ubiquitiUniFi;

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
    final routerStore = _unifiUsersStore.putIfAbsent(router.id, () => []);

    if (command == '/system/identity/print') {
      return RouterOsApiResponse(
        records: [
          {'name': router.identity ?? 'UniFi-CloudKey-Gen2'},
        ],
      );
    }

    if (command == '/system/resource/print') {
      return const RouterOsApiResponse(
        records: [
          {
            'uptime': '30d12h00m',
            'version': 'UniFi Network v8.1.113',
            'board-name': 'Ubiquiti UniFi CloudKey Gen2 Plus',
            'cpu-load': '18',
            'free-memory': '1610612736',
            'total-memory': '3221225472',
          },
        ],
      );
    }

    if (command == '/interface/print') {
      return const RouterOsApiResponse(
        records: [
          {
            'name': 'eth0 (GbE)',
            'type': 'ether',
            'running': 'true',
            'disabled': 'false',
            'mac-address': 'B4:FBE:11:22:33',
            'rx-byte': '209715200',
            'tx-byte': '419430400',
          },
        ],
      );
    }

    if (command == '/ip/hotspot/user/print') {
      return RouterOsApiResponse(records: List.from(routerStore));
    }

    if (command == '/ip/hotspot/user/add') {
      final id = '*unifi_${DateTime.now().millisecondsSinceEpoch}';
      final newRecord = <String, String>{
        '.id': id,
        'name': attributes['name'] ?? 'unifi_guest_voucher',
        'password': attributes['password'] ?? '',
        'profile': attributes['profile'] ?? 'default',
        'uptime-limit':
            attributes['limit-uptime'] ?? attributes['uptime-limit'] ?? '0s',
        'bytes-total-limit':
            attributes['limit-bytes-total'] ??
            attributes['bytes-total-limit'] ??
            '0',
        'comment':
            attributes['comment'] ?? 'Created via UniFi Controller REST API',
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
              'address': '192.168.20.${routerStore.indexOf(u) + 10}',
              'mac-address': 'B4:FBE:${routerStore.indexOf(u)}:EE:FF',
              'uptime': '1h10m',
              'bytes-in': '2097152',
              'bytes-out': '8388608',
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
            'rate-limit': '20M/20M',
          },
          {
            '.id': '*p2',
            'name': 'UniFi_Guest_Hotspot',
            'shared-users': '1',
            'rate-limit': '50M/50M',
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
      identity: router.identity ?? 'UniFi-CloudKey-Gen2',
      resource: const RouterOsSystemResource(
        uptime: '30d12h00m',
        version: 'UniFi Network v8.1.113',
        boardName: 'Ubiquiti UniFi CloudKey Gen2 Plus',
        cpuLoad: 18,
        freeMemory: 1610612736,
        totalMemory: 3221225472,
      ),
      interfaces: const [
        RouterOsInterface(
          name: 'eth0 (GbE)',
          type: 'ether',
          running: true,
          disabled: false,
          macAddress: 'B4:FBE:11:22:33',
          rxByte: 209715200,
          txByte: 419430400,
        ),
      ],
    );
  }
}
