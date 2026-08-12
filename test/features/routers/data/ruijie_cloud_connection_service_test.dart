import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/storage/router_credentials.dart';
import 'package:wirespot/features/routers/data/ruijie_cloud_connection_service.dart';
import 'package:wirespot/features/routers/domain/entities/router_entity.dart';

void main() {
  test('tests Ruijie Cloud through the device-list endpoint', () async {
    Uri? requestedUri;
    final service = RuijieCloudConnectionService(
      readCredentials: (_) async => const RouterCredentials(
        username: 'operator',
        password: '',
        accessToken: 'cloud-token',
      ),
      requestDevices: (uri) async {
        requestedUri = uri;
        return Response<dynamic>(
          requestOptions: RequestOptions(path: uri.path),
          statusCode: 200,
        );
      },
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
    expect(requestedUri.toString(), contains('/service/api/maint/devices'));
    expect(requestedUri!.queryParameters['access_token'], 'cloud-token');
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
        requestDevices: (uri) async => Response<dynamic>(
          requestOptions: RequestOptions(path: uri.path),
          statusCode: 401,
        ),
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
        requestDevices: (uri) => throw DioException(
          requestOptions: RequestOptions(path: uri.path),
          type: DioExceptionType.connectionError,
        ),
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
