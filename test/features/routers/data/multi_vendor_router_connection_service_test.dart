import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/api/routeros_api_response.dart';
import 'package:wirespot/core/api/routeros_models.dart';
import 'package:wirespot/features/routers/data/generic_router_connection_service.dart';
import 'package:wirespot/features/routers/data/multi_vendor_router_connection_service.dart';
import 'package:wirespot/features/routers/data/omada_connection_service.dart';
import 'package:wirespot/features/routers/data/openwrt_connection_service.dart';
import 'package:wirespot/features/routers/data/ruijie_cloud_connection_service.dart';
import 'package:wirespot/features/routers/data/unifi_connection_service.dart';
import 'package:wirespot/features/routers/domain/entities/router_entity.dart';
import 'package:wirespot/features/routers/domain/services/router_connector.dart';

void main() {
  test('routes MikroTik commands to the RouterOS connector', () async {
    final mikrotik = _RecordingConnector(RouterVendor.mikrotik);
    final service = MultiVendorRouterConnectionService(connectors: [mikrotik]);

    final response = await service.execute(
      const RouterEntity(
        id: 'router-1',
        name: 'Main',
        host: '10.0.0.1',
        username: 'admin',
      ),
      '/system/identity/print',
    );

    expect(response.records.single['connector'], 'mikrotik');
    expect(mikrotik.commands, ['/system/identity/print']);
  });

  test('all 6 router vendors execute commands on their active connectors', () async {
    final ruijie = RuijieCloudConnectionService(
      readCredentials: (_) async => null,
      requestDevices: (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'data': [
            {'id': 'dev1', 'name': 'Ruijie Gateway'},
          ],
        },
      ),
    );
    final openwrt = OpenWrtConnectionService();
    final omada = OmadaConnectionService();
    final unifi = UniFiConnectionService();
    final generic = GenericRouterConnectionService();

    final service = MultiVendorRouterConnectionService(
      connectors: [ruijie, openwrt, omada, unifi, generic],
    );

    final vendors = [
      RouterVendor.ruijie,
      RouterVendor.openWrt,
      RouterVendor.tpLinkOmada,
      RouterVendor.ubiquitiUniFi,
      RouterVendor.generic,
    ];

    for (final vendor in vendors) {
      final router = RouterEntity(
        id: 'r_${vendor.name}',
        name: 'Test ${vendor.label}',
        host: '192.168.1.1',
        username: 'admin',
        vendor: vendor,
      );

      final isConnected = await service.testConnection(router);
      expect(isConnected, isTrue);

      final identity = await service.execute(router, '/system/identity/print');
      expect(identity.records, isNotEmpty);

      final addedUser = await service.execute(
        router,
        '/ip/hotspot/user/add',
        attributes: {'name': 'test_${vendor.name}', 'password': 'pass'},
      );
      expect(addedUser.records.single['name'], 'test_${vendor.name}');

      final users = await service.execute(router, '/ip/hotspot/user/print');
      expect(users.records.any((u) => u['name'] == 'test_${vendor.name}'), isTrue);

      final snapshot = await service.getSnapshot(router);
      expect(snapshot.identity, isNotEmpty);
      expect(snapshot.resource.uptime, isNotEmpty);
    }
  });
}

class _RecordingConnector implements RouterConnector {
  _RecordingConnector(this.vendor);

  @override
  final RouterVendor vendor;

  final commands = <String>[];

  @override
  Future<RouterOsApiResponse> execute(
    RouterEntity router,
    String command, {
    Map<String, String> attributes = const {},
    List<String> queries = const [],
  }) async {
    commands.add(command);
    return RouterOsApiResponse(
      records: [
        {'connector': vendor.name},
      ],
    );
  }

  @override
  Future<RouterOsRouterSnapshot> getSnapshot(RouterEntity router) {
    throw UnimplementedError();
  }

  @override
  Future<bool> testConnection(RouterEntity router) async => true;

  @override
  Stream<Map<String, String>> stream(
    RouterEntity router,
    String command, {
    Map<String, String> attributes = const {},
    List<String> queries = const [],
  }) {
    throw UnimplementedError();
  }
}
