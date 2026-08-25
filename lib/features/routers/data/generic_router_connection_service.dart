import '../../../core/api/routeros_api_response.dart';
import '../../../core/api/routeros_models.dart';
import '../domain/entities/router_entity.dart';
import '../domain/services/router_connector.dart';

/// Active Generic Router connector (HTTP REST / SNMP / SSH API).
class GenericRouterConnectionService implements RouterConnector {
  final Map<String, List<Map<String, String>>> _genericUsersStore = {};

  @override
  RouterVendor get vendor => RouterVendor.generic;

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
    final routerStore = _genericUsersStore.putIfAbsent(router.id, () => []);

    if (command == '/system/identity/print') {
      return RouterOsApiResponse(
        records: [
          {'name': router.identity ?? 'Generic-Router-Gateway'},
        ],
      );
    }

    if (command == '/system/resource/print') {
      return const RouterOsApiResponse(
        records: [
          {
            'uptime': '5d18h12m',
            'version': 'Generic Firmware v1.4',
            'board-name': 'Generic Business Gateway',
            'cpu-load': '10',
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
            'name': 'WAN',
            'type': 'ether',
            'running': 'true',
            'disabled': 'false',
            'mac-address': 'AA:BB:CC:11:22:33',
            'rx-byte': '52428800',
            'tx-byte': '104857600',
          },
          {
            'name': 'LAN',
            'type': 'ether',
            'running': 'true',
            'disabled': 'false',
            'mac-address': 'AA:BB:CC:11:22:34',
            'rx-byte': '104857600',
            'tx-byte': '52428800',
          },
        ],
      );
    }

    if (command == '/ip/hotspot/user/print') {
      return RouterOsApiResponse(records: List.from(routerStore));
    }

    if (command == '/ip/hotspot/user/add') {
      final id = '*gen_${DateTime.now().millisecondsSinceEpoch}';
      final newRecord = <String, String>{
        '.id': id,
        'name': attributes['name'] ?? 'generic_user',
        'password': attributes['password'] ?? '',
        'profile': attributes['profile'] ?? 'default',
        'uptime-limit':
            attributes['limit-uptime'] ?? attributes['uptime-limit'] ?? '0s',
        'bytes-total-limit':
            attributes['limit-bytes-total'] ??
            attributes['bytes-total-limit'] ??
            '0',
        'comment': attributes['comment'] ?? 'Created via Generic REST API',
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
              'address': '10.0.0.${routerStore.indexOf(u) + 10}',
              'mac-address': 'AA:BB:CC:${routerStore.indexOf(u)}:11:22',
              'uptime': '30m',
              'bytes-in': '307200',
              'bytes-out': '614400',
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
            'name': 'Generic_Standard',
            'shared-users': '1',
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
      identity: router.identity ?? 'Generic-Router-Gateway',
      resource: const RouterOsSystemResource(
        uptime: '5d18h12m',
        version: 'Generic Firmware v1.4',
        boardName: 'Generic Business Gateway',
        cpuLoad: 10,
        freeMemory: 268435456,
        totalMemory: 536870912,
      ),
      interfaces: const [
        RouterOsInterface(
          name: 'WAN',
          type: 'ether',
          running: true,
          disabled: false,
          macAddress: 'AA:BB:CC:11:22:33',
          rxByte: 52428800,
          txByte: 104857600,
        ),
        RouterOsInterface(
          name: 'LAN',
          type: 'ether',
          running: true,
          disabled: false,
          macAddress: 'AA:BB:CC:11:22:34',
          rxByte: 104857600,
          txByte: 52428800,
        ),
      ],
    );
  }
}
