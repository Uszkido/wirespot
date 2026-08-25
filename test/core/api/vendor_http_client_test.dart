import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/api/vendor_http_client.dart';
import 'package:wirespot/features/routers/domain/entities/router_entity.dart';

void main() {
  group('VendorHttpClient tests', () {
    final client = VendorHttpClient();

    test(
      'sendRequest returns normalized map response for Ruijie Cloud',
      () async {
        final router = RouterEntity(
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
        final router = RouterEntity(
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
      },
    );
  });
}
