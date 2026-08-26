import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/api/vendor_http_client.dart';
import 'package:wirespot/features/routers/domain/entities/router_entity.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({this.responseBody = '{"status":"success"}'});
  final String responseBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      responseBody,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('VendorHttpClient tests', () {
    test(
      'sendRequest returns normalized map response for Ruijie Cloud',
      () async {
        final dio = Dio();
        dio.httpClientAdapter = _StubAdapter(
          responseBody: '{"status":"success", "data": []}',
        );
        final client = VendorHttpClient(dio: dio);

        final router = const RouterEntity(
          id: 'r_ruijie',
          name: 'Ruijie Cloud Gateway',
          host: 'cloud.ruijienetworks.com',
          username: 'admin',
          vendor: RouterVendor.ruijie,
          apiPort: 443,
          useSsl: true,
        );

        final response = await client.sendRequest(
          router: router,
          path: '/api/v1/devices',
          token: 'ruijie_test_token',
        );

        expect(response, isNotNull);
        expect(response.containsKey('status'), isTrue);
      },
    );

    test(
      'sendRequest returns normalized map response for OpenWrt ubus',
      () async {
        final dio = Dio();
        dio.httpClientAdapter = _StubAdapter(
          responseBody:
              '{"jsonrpc":"2.0", "id": 1, "result": [0, {"board_name": "OpenWrt"}]}',
        );
        final client = VendorHttpClient(dio: dio);

        final router = const RouterEntity(
          id: 'r_openwrt',
          name: 'OpenWrt LuCI Gateway',
          host: '192.168.1.1',
          username: 'root',
          vendor: RouterVendor.openWrt,
          apiPort: 80,
          useSsl: false,
        );

        final response = await client.sendRequest(
          router: router,
          path: '/ubus',
          method: 'POST',
          data: {
            'jsonrpc': '2.0',
            'id': 1,
            'method': 'call',
            'params': [
              '00000000000000000000000000000000',
              'system',
              'board',
              {},
            ],
          },
        );

        expect(response, isNotNull);
        expect(response['jsonrpc'], equals('2.0'));
      },
    );
  });
}
