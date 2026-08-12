import 'package:dio/dio.dart';

import '../../../core/api/routeros_api_exception.dart';
import '../../../core/api/routeros_api_response.dart';
import '../../../core/api/routeros_models.dart';
import '../../../core/storage/router_credential_store.dart';
import '../../../core/storage/router_credentials.dart';
import '../domain/entities/router_entity.dart';
import '../domain/entities/ruijie_cloud_device.dart';
import '../domain/services/router_connector.dart';

typedef RuijieDeviceRequest = Future<Response<dynamic>> Function(Uri uri);
typedef RuijieCredentialsReader =
    Future<RouterCredentials?> Function(String routerId);

/// Verifies access to Ruijie Cloud through its documented device-list endpoint.
/// Hotspot changes remain unavailable until their API contracts are verified.
class RuijieCloudConnectionService implements RouterConnector {
  RuijieCloudConnectionService({
    RouterCredentialStore? credentialStore,
    RuijieDeviceRequest? requestDevices,
    RuijieCredentialsReader? readCredentials,
  }) : assert(credentialStore != null || readCredentials != null),
       _credentialStore = credentialStore,
       _requestDevices = requestDevices ?? _defaultRequestDevices,
       _readCredentials = readCredentials;

  final RouterCredentialStore? _credentialStore;
  final RuijieDeviceRequest _requestDevices;
  final RuijieCredentialsReader? _readCredentials;

  @override
  RouterVendor get vendor => RouterVendor.ruijie;

  @override
  Future<bool> testConnection(RouterEntity router) async {
    try {
      final response = await _requestDeviceList(router);
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } on DioException {
      return false;
    }
  }

  Future<List<RuijieCloudDevice>> discoverDevices(RouterEntity router) async {
    final response = await _requestDeviceList(router);
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw const RouterOsApiException(
        'Ruijie Cloud did not return a successful device-list response.',
        category: 'connection',
      );
    }
    return _deviceRecords(response.data)
        .map(RuijieCloudDevice.fromJson)
        .where((device) => device.id.isNotEmpty || device.name.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<RouterOsApiResponse> execute(
    RouterEntity router,
    String command, {
    Map<String, String> attributes = const {},
    List<String> queries = const [],
  }) {
    throw _unsupportedOperation();
  }

  @override
  Future<RouterOsRouterSnapshot> getSnapshot(RouterEntity router) {
    throw _unsupportedOperation();
  }

  Future<String> _accessTokenFor(RouterEntity router) async {
    final credentials =
        await (_readCredentials?.call(router.id) ??
            _credentialStore!.read(router.id));
    final token = credentials?.accessToken ?? credentials?.password ?? '';
    if (token.isEmpty) {
      throw const RouterOsAuthenticationException(
        'Ruijie Cloud access token is not available in secure storage.',
      );
    }
    return token;
  }

  Future<Response<dynamic>> _requestDeviceList(RouterEntity router) async {
    final token = await _accessTokenFor(router);
    return _requestDevices(_deviceListUri(router, token));
  }

  List<Map<String, Object?>> _deviceRecords(dynamic payload) {
    final data = payload is Map
        ? payload['data'] ?? payload['devices']
        : payload;
    final records = data is Map
        ? data['list'] ?? data['devices'] ?? data['records']
        : data;
    if (records is! List) {
      return const [];
    }
    return records
        .whereType<Map>()
        .map((record) => Map<String, Object?>.from(record))
        .toList(growable: false);
  }

  Uri _deviceListUri(RouterEntity router, String token) {
    return Uri(
      scheme: router.useSsl ? 'https' : 'http',
      host: router.host.trim(),
      port: router.apiPort,
      path: '/service/api/maint/devices',
      queryParameters: {'access_token': token},
    );
  }

  static Future<Response<dynamic>> _defaultRequestDevices(Uri uri) {
    return Dio().getUri<dynamic>(uri);
  }

  RouterOsApiException _unsupportedOperation() {
    return const RouterOsApiException(
      'Ruijie Cloud is currently limited to connection verification and device discovery. '
      'Hotspot management will be enabled after its API contract is verified.',
      category: 'unsupported_operation',
    );
  }
}
