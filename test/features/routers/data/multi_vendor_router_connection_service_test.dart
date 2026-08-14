import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/api/routeros_api_exception.dart';
import 'package:wirespot/core/api/routeros_api_response.dart';
import 'package:wirespot/core/api/routeros_models.dart';
import 'package:wirespot/features/routers/data/multi_vendor_router_connection_service.dart';
import 'package:wirespot/features/routers/data/planned_router_connector.dart';
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

  test('planned connectors return an unsupported vendor error', () async {
    final service = MultiVendorRouterConnectionService(
      connectors: const [PlannedRouterConnector(RouterVendor.ruijie)],
    );

    await expectLater(
      service.testConnection(
        const RouterEntity(
          id: 'router-ruijie',
          name: 'Reyee Guest',
          host: '192.168.110.1',
          username: 'admin',
          vendor: RouterVendor.ruijie,
        ),
      ),
      throwsA(
        isA<RouterOsApiException>()
            .having((error) => error.category, 'category', 'unsupported_vendor')
            .having(
              (error) => error.message,
              'message',
              contains('planned connector'),
            )
            .having(
              (error) => error.message,
              'message',
              contains('Ruijie Cloud or local controller'),
            ),
      ),
    );
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
