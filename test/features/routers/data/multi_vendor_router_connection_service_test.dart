import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/api/routeros_api_response.dart';
import 'package:wirespot/core/api/routeros_api_exception.dart';
import 'package:wirespot/core/api/routeros_models.dart';
import 'package:wirespot/core/api/vendor_http_client.dart';
import 'package:wirespot/core/storage/router_credentials.dart';
import 'package:wirespot/features/routers/data/generic_router_connection_service.dart';
import 'package:wirespot/features/routers/data/multi_vendor_router_connection_service.dart';
import 'package:wirespot/features/routers/data/omada_connection_service.dart';
import 'package:wirespot/features/routers/data/openwrt_connection_service.dart';
import 'package:wirespot/features/routers/data/ruijie_cloud_connection_service.dart';
import 'package:wirespot/features/routers/data/unifi_connection_service.dart';
import 'package:wirespot/features/routers/domain/entities/router_entity.dart';
import 'package:wirespot/features/routers/domain/services/router_connector.dart';

/// Stub Dio adapter that returns a minimal successful JSON response.
VendorHttpClient _stubHttp200() {
  final dio = Dio();
  dio.httpClientAdapter = _StubAdapter();
  return VendorHttpClient(dio: dio);
}

void main() {
  test(
    'UniFi executes a guarded reboot for an explicit site and device',
    () async {
      final client = _RecordingUniFiClient();
      final service = UniFiConnectionService(httpClient: client);
      final router = const RouterEntity(
        id: 'unifi-1',
        name: 'UniFi gateway',
        host: '192.168.1.10',
        username: 'operator',
        vendor: RouterVendor.ubiquitiUniFi,
      );

      expect(
        () => service.execute(router, '/system/reboot'),
        throwsA(isA<RouterOsApiException>()),
      );
      final response = await service.execute(
        router,
        '/system/reboot',
        attributes: {'siteId': 'site/1', 'deviceId': 'gateway-1'},
      );

      expect(response.records.single['status'], 'reboot-requested');
      expect(client.method, 'POST');
      expect(
        client.path,
        '/proxy/network/integration/v1/sites/site%2F1/devices/gateway-1/actions',
      );
      expect(client.data, {'action': 'RESTART'});
    },
  );

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

  test(
    'all 6 router vendors execute commands on their active connectors',
    () async {
      final stubHttp = _stubHttp200();
      final ruijie = RuijieCloudConnectionService(
        readCredentials: (_) async => const RouterCredentials(
          username: 'operator',
          password: '',
          accessToken: 'stub-cloud-token',
        ),
        httpClient: stubHttp,
        requestDevices: (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {
            'data': [
              {
                'id': 'dev1',
                'name': 'Ruijie Gateway',
                'model': 'RG-EG105GW',
                'version': '3.0.28',
                'status': 'online',
                'cpuLoad': 12,
                'uptimeSeconds': 7200,
              },
            ],
          },
        ),
      );
      final openwrt = OpenWrtConnectionService(
        httpClient: _OpenWrtHttpClient(),
      );
      final omada = OmadaConnectionService(httpClient: _OmadaHttpClient());
      final unifi = UniFiConnectionService(httpClient: _UniFiHttpClient());
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

        if (vendor == RouterVendor.mikrotik) {
          final identity = await service.execute(
            router,
            '/system/identity/print',
          );
          expect(identity.records, isNotEmpty);
        } else {
          expect(
            () => service.execute(router, '/system/identity/print'),
            throwsA(isA<RouterOsApiException>()),
          );
        }

        if (vendor == RouterVendor.mikrotik) {
          final snapshot = await service.getSnapshot(router);
          expect(snapshot.identity, isNotEmpty);
          expect(snapshot.resource.uptime, isNotEmpty);
        } else if (vendor == RouterVendor.openWrt) {
          final snapshot = await service.getSnapshot(router);
          expect(snapshot.identity, 'openwrt-gateway');
          expect(snapshot.resource.version, '23.05.5');
          expect(snapshot.resource.totalMemory, 524288);
          expect(snapshot.interfaces.single.name, 'eth0');
        } else if (vendor == RouterVendor.ruijie) {
          final snapshot = await service.getSnapshot(router);
          expect(snapshot.identity, 'Ruijie Gateway');
          expect(snapshot.resource.version, '3.0.28');
          expect(snapshot.interfaces.single.running, isTrue);
        } else if (vendor == RouterVendor.tpLinkOmada) {
          final snapshot = await service.getSnapshot(router);
          expect(snapshot.identity, 'Omada Gateway');
          expect(snapshot.resource.version, '1.4.2');
          expect(snapshot.interfaces.single.running, isTrue);
        } else if (vendor == RouterVendor.ubiquitiUniFi) {
          final snapshot = await service.getSnapshot(router);
          expect(snapshot.identity, 'UniFi Gateway');
          expect(snapshot.resource.version, '9.4.17');
          expect(snapshot.interfaces.single.running, isTrue);
        } else {
          expect(
            () => service.getSnapshot(router),
            throwsA(isA<RouterOsApiException>()),
          );
        }
      }
    },
  );
}

class _RecordingUniFiClient extends VendorHttpClient {
  String? method;
  String? path;
  dynamic data;

  @override
  Future<Map<String, dynamic>> sendRequest({
    required RouterEntity router,
    required String path,
    String method = 'GET',
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    String? token,
    String? username,
    String? password,
  }) async {
    this.method = method;
    this.path = path;
    this.data = data;
    return const {'status': 'success'};
  }
}

class _UniFiHttpClient extends VendorHttpClient {
  @override
  Future<Map<String, dynamic>> sendRequest({
    required RouterEntity router,
    required String path,
    String method = 'GET',
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    String? token,
    String? username,
    String? password,
  }) async {
    if (path.endsWith('/sites')) {
      return {
        'data': [
          {'id': 'site-1', 'name': 'Main site'},
        ],
      };
    }
    return {
      'data': [
        {
          'id': 'gateway-1',
          'name': 'UniFi Gateway',
          'model': 'UDM Pro',
          'version': '9.4.17',
          'status': 'online',
          'cpuLoad': 18,
          'uptimeSeconds': 3600,
        },
      ],
    };
  }
}

class _OmadaHttpClient extends VendorHttpClient {
  @override
  Future<Map<String, dynamic>> sendRequest({
    required RouterEntity router,
    required String path,
    String method = 'GET',
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    String? token,
    String? username,
    String? password,
  }) async {
    if (path.endsWith('/sites')) {
      return {
        'data': [
          {'id': 'site-1', 'name': 'Main site'},
        ],
      };
    }
    return {
      'data': [
        {
          'id': 'gateway-1',
          'name': 'Omada Gateway',
          'model': 'ER7206',
          'version': '1.4.2',
          'status': 'online',
          'cpuLoad': 21,
          'uptimeSeconds': 1800,
        },
      ],
    };
  }
}

class _OpenWrtHttpClient extends VendorHttpClient {
  @override
  Future<Map<String, dynamic>> sendRequest({
    required RouterEntity router,
    required String path,
    String method = 'GET',
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    String? token,
    String? username,
    String? password,
  }) async {
    final params = data is Map ? data['params'] : null;
    final object = params is List && params.length > 1 ? params[1] : null;
    final rpcMethod = params is List && params.length > 2 ? params[2] : null;
    if (object == 'system' && rpcMethod == 'board') {
      return {
        'result': [
          0,
          {
            'model': 'MediaTek MT7621',
            'release': {'version': '23.05.5'},
          },
        ],
      };
    }
    if (object == 'system' && rpcMethod == 'info') {
      return {
        'result': [
          0,
          {
            'hostname': 'openwrt-gateway',
            'uptime': 3725,
            'load': [1024, 512, 256],
            'memory': {'total': 524288, 'free': 262144},
          },
        ],
      };
    }
    return {
      'result': [
        0,
        {
          'interface': [
            {'device': 'eth0', 'up': true},
          ],
        },
      ],
    };
  }
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

/// Stub Dio adapter that always returns HTTP 200 with an empty JSON body.
class _StubAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString('{"status":"ok"}', 200);
  }

  @override
  void close({bool force = false}) {}
}
