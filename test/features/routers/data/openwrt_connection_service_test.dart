import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/api/vendor_http_client.dart';
import 'package:wirespot/features/routers/data/openwrt_connection_service.dart';
import 'package:wirespot/features/routers/domain/entities/router_entity.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.body);

  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    body,
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

RouterEntity _router() => const RouterEntity(
  id: 'openwrt-1',
  name: 'OpenWrt gateway',
  host: '192.0.2.10',
  username: 'root',
  vendor: RouterVendor.openWrt,
  apiPort: 80,
  useSsl: false,
);

void main() {
  test('executes the standard OpenWrt system reboot method', () async {
    final dio = Dio()..httpClientAdapter = _StubAdapter('{"result":[0]}');
    final service = OpenWrtConnectionService(
      httpClient: VendorHttpClient(dio: dio),
    );

    final response = await service.execute(_router(), '/system/reboot');

    expect(response.records.single['status'], 'reboot-requested');
  });

  test('maps OpenWrt interface dump to normalized records', () async {
    final dio = Dio()
      ..httpClientAdapter = _StubAdapter(
        '{"result":[0,{"interface":[{"device":"br-lan","up":true}]}]}',
      );
    final service = OpenWrtConnectionService(
      httpClient: VendorHttpClient(dio: dio),
    );

    final response = await service.execute(_router(), '/interface/print');

    expect(response.records, hasLength(1));
    expect(response.records.single['name'], 'br-lan');
    expect(response.records.single['up'], 'true');
  });

  test('keeps unsupported hotspot mutations fail-closed', () async {
    final service = OpenWrtConnectionService();

    expect(
      () => service.execute(_router(), '/ip/hotspot/user/add'),
      throwsA(
        predicate(
          (error) => error.toString().contains(
            'does not expose a normalized command adapter',
          ),
        ),
      ),
    );
  });
}
