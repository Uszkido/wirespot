import 'package:dio/dio.dart';

import '../../../core/api/routeros_api_exception.dart';
import '../../../core/api/routeros_api_response.dart';
import '../../../core/api/routeros_models.dart';
import '../../../core/api/vendor_http_client.dart';
import '../../../core/storage/router_credential_store.dart';
import '../../../core/storage/router_credentials.dart';
import '../domain/entities/router_entity.dart';
import '../domain/entities/ruijie_cloud_device.dart';
import '../domain/services/router_connector.dart';
import 'vendor_mutation_support.dart';

typedef RuijieDeviceRequest = Future<Response<dynamic>> Function(Uri uri);
typedef RuijieCredentialsReader =
    Future<RouterCredentials?> Function(String routerId);

/// Ruijie/Reyee Cloud authentication, device discovery, and read-only
/// dashboard connector. Mutations remain fail-closed until the target cloud
/// API version and site model are selected by the operator.
class RuijieCloudConnectionService implements RouterConnector {
  RuijieCloudConnectionService({
    RouterCredentialStore? credentialStore,
    RuijieDeviceRequest? requestDevices,
    RuijieCredentialsReader? readCredentials,
    VendorHttpClient? httpClient,
  }) : assert(credentialStore != null || readCredentials != null),
       _credentialStore = credentialStore,
       _requestDevices = requestDevices ?? _defaultRequestDevices,
       _readCredentials = readCredentials,
       _http = httpClient ?? VendorHttpClient();

  final RouterCredentialStore? _credentialStore;
  final RuijieDeviceRequest _requestDevices;
  final RuijieCredentialsReader? _readCredentials;
  final VendorHttpClient _http;

  @override
  RouterVendor get vendor => RouterVendor.ruijie;

  @override
  Future<bool> testConnection(RouterEntity router) async {
    try {
      final token = await _accessTokenFor(router);
      final result = await _http.sendRequest(
        router: router,
        path: '/service/api/maint/devices',
        token: token,
      );
      return result.isNotEmpty && result['status'] != 'error';
    } catch (_) {
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
  }) async {
    throw unsupportedVendorCommand(router, command);
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
    final response = await _requestDeviceList(router);
    final records = _deviceRecords(response.data);
    if (records.isEmpty) {
      throw StateError('Ruijie Cloud controller is unreachable.');
    }
    final primary = records.first;
    final uptime = _number(primary, const [
      'uptime',
      'uptimeSeconds',
      'uptime_seconds',
    ]);
    return RouterOsRouterSnapshot(
      identity:
          _value(primary, const [
            'name',
            'deviceName',
            'device_name',
            'hostname',
            'id',
          ]) ??
          router.name,
      resource: RouterOsSystemResource(
        uptime: _formatUptime(uptime.toInt()),
        version:
            _value(primary, const [
              'version',
              'firmwareVersion',
              'firmware_version',
            ]) ??
            '',
        boardName:
            _value(primary, const ['model', 'deviceModel', 'device_model']) ??
            '',
        cpuLoad: _number(primary, const [
          'cpuLoad',
          'cpuUtilization',
          'cpu_utilization',
        ]).clamp(0, 100).toInt(),
        freeMemory: _number(primary, const [
          'freeMemory',
          'memoryFree',
          'memory_free',
        ]).toInt(),
        totalMemory: _number(primary, const [
          'totalMemory',
          'memoryTotal',
          'memory_total',
        ]).toInt(),
      ),
      interfaces: [
        for (final device in records)
          RouterOsInterface(
            name:
                _value(device, const [
                  'name',
                  'deviceName',
                  'device_name',
                  'id',
                ]) ??
                '',
            type:
                _value(device, const [
                  'type',
                  'deviceType',
                  'device_type',
                  'model',
                ]) ??
                '',
            running: _isOnline(device),
            disabled: false,
            macAddress: _value(device, const [
              'mac',
              'macAddress',
              'mac_address',
            ]),
          ),
      ],
    );
  }

  String? _value(Map<String, Object?> record, List<String> keys) {
    for (final key in keys) {
      final value = record[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  num _number(Map<String, Object?> record, List<String> keys) {
    for (final key in keys) {
      final value = record[key];
      if (value is num) return value;
      final parsed = num.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return 0;
  }

  bool _isOnline(Map<String, Object?> record) {
    final status = _value(record, const [
      'status',
      'deviceStatus',
      'device_status',
      'state',
    ]);
    return record['online'] == true ||
        record['connected'] == true ||
        status?.toLowerCase() == 'online' ||
        status?.toLowerCase() == 'connected' ||
        status?.toLowerCase() == 'up';
  }

  String _formatUptime(int seconds) {
    if (seconds <= 0) return '';
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remaining = seconds % 60;
    return '${days}d ${hours}h ${minutes}m ${remaining}s';
  }

  Future<String> _accessTokenFor(RouterEntity router) async {
    final credentials =
        await (_readCredentials?.call(router.id) ??
            _credentialStore!.read(router.id));
    final token = credentials?.accessToken ?? credentials?.password ?? '';
    if (token.isEmpty) {
      throw RouterOsApiException(
        'Ruijie Cloud access token is missing. Add the token in router credentials before testing this connection.',
        category: 'authentication',
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
    if (records is! List) return const [];
    return records
        .whereType<Map>()
        .map((record) => Map<String, Object?>.from(record))
        .toList(growable: false);
  }

  Uri _deviceListUri(RouterEntity router, String token) => Uri(
    scheme: router.useSsl ? 'https' : 'http',
    host: router.host.trim(),
    port: router.apiPort,
    path: '/service/api/maint/devices',
    queryParameters: {'access_token': token},
  );

  static Future<Response<dynamic>> _defaultRequestDevices(Uri uri) =>
      Dio().getUri<dynamic>(uri);
}
