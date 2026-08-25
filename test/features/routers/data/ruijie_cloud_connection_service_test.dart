import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/api/vendor_http_client.dart';
import 'package:wirespot/core/storage/router_credentials.dart';
import 'package:wirespot/features/routers/data/ruijie_cloud_connection_service.dart';
import 'package:wirespot/features/routers/domain/entities/router_entity.dart';

VendorHttpClient _stubHttp({required int statusCode}) {
  final dio = Dio();
  dio.httpClientAdapter = _StubAdapter(statusCode: statusCode);
  return VendorHttpClient(dio: dio);
}

VendorHttpClient _throwingHttp() {
  final dio = Dio();
  dio.httpClientAdapter = _ThrowingAdapter();
  return VendorHttpClient(dio: dio);
}

void main() {
  test('tests Ruijie Cloud through the device-list endpoint', () async {
    String? requestedPath;
    final dio = Dio();
    dio.httpClientAdapter = _CapturingAdapter(onRequest: (path) {
      requestedPath = path;
    });

    final service = RuijieCloudConnectionService(
      readCredentials: (_) async => const RouterCredentials(
        username: 'operator',
        password: '',
        accessToken: 'cloud-token',
      ),
      httpClient: VendorHttpClient(dio: dio),
    );

    final connected = await service.testConnection(
      const RouterEntity(
        id: 'ruijie-1',
        name: 'Guest cloud',
        host: 'cloud-as.ruijienetworks.com',
        username: 'operator',
        vendor: RouterVendor.ruijie,
        apiPort: 443,
        useSsl: true,
      ),
    );

    expect(connected, isTrue);
    expect(requestedPath, contains('/service/api/maint/devices'));
  });

  test(
    'reports a failed connection when Ruijie Cloud rejects the request',
    () async {
      final service = RuijieCloudConnectionService(
        readCredentials: (_) async => const RouterCredentials(
          username: 'operator',
          password: '',
          accessToken: 'expired-token',
        ),
        httpClient: _stubHttp(statusCode: 401),
      );

      final connected = await service.testConnection(_ruijieRouter);

      expect(connected, isFalse);
    },
  );

  test(
    'reports a failed connection when Ruijie Cloud is unavailable',
    () async {
      final service = RuijieCloudConnectionService(
        readCredentials: (_) async => const RouterCredentials(
          username: 'operator',
          password: '',
          accessToken: 'cloud-token',
        ),
        httpClient: _throwingHttp(),
      );

      final connected = await service.testConnection(_ruijieRouter);

      expect(connected, isFalse);
    },
  );

  test('discovers devices from a Ruijie Cloud data response', () async {
    final service = RuijieCloudConnectionService(
      readCredentials: (_) async => const RouterCredentials(
        username: 'operator',
        password: '',
        accessToken: 'cloud-token',
      ),
      requestDevices: (uri) async => Response<dynamic>(
        requestOptions: RequestOptions(path: uri.path),
        statusCode: 200,
        data: {
          'data': [
            {
              'deviceId': 'gw-1',
              'deviceName': 'Reception gateway',
              'model': 'RG-EG105GW',
              'status': 'online',
            },
          ],
        },
      ),
    );

    final devices = await service.discoverDevices(_ruijieRouter);

    expect(devices, hasLength(1));
    expect(devices.single.id, 'gw-1');
    expect(devices.single.name, 'Reception gateway');
    expect(devices.single.status, 'online');
  });
}

const _ruijieRouter = RouterEntity(
  id: 'ruijie-1',
  name: 'Guest cloud',
  host: 'cloud-as.ruijienetworks.com',
  username: 'operator',
  vendor: RouterVendor.ruijie,
  apiPort: 443,
  useSsl: true,
);

/// Adapter that always returns a fixed status code with empty body.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({required this.statusCode});
  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString('{}', statusCode);
  }

  @override
  void close({bool force = false}) {}
}

/// Adapter that captures the requested path and returns 200.
class _CapturingAdapter implements HttpClientAdapter {
  _CapturingAdapter({required this.onRequest});
  final void Function(String path) onRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    onRequest(options.uri.path);
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

/// Adapter that always throws a connection error.
class _ThrowingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
    );
  }

  @override
  void close({bool force = false}) {}
}
