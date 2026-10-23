import '../../../core/api/routeros_api_response.dart';
import '../../../core/api/routeros_models.dart';
import '../../../core/api/vendor_http_client.dart';
import '../../../core/storage/router_credential_store.dart';
import '../domain/entities/router_entity.dart';
import '../domain/services/router_connector.dart';
import 'vendor_mutation_support.dart';

/// Omada Controller connection and read-only dashboard connector.
///
/// The controller API has changed names between releases, so reads accept the
/// documented OpenAPI paths and normalize the common site/device envelopes.
/// Mutations remain fail-closed until a controller-version-specific contract
/// is selected by the operator.
class OmadaConnectionService implements RouterConnector {
  OmadaConnectionService({
    VendorHttpClient? httpClient,
    RouterCredentialStore? credentialStore,
  }) : _http = httpClient ?? VendorHttpClient(),
       _credentialStore = credentialStore;

  final VendorHttpClient _http;
  final RouterCredentialStore? _credentialStore;

  @override
  RouterVendor get vendor => RouterVendor.tpLinkOmada;

  @override
  Future<bool> testConnection(RouterEntity router) async {
    try {
      final result = await _request(router, '/openapi/v1/sites');
      return _records(result).isNotEmpty;
    } catch (_) {
      return false;
    }
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
    final sitesResponse = await _request(router, '/openapi/v1/sites');
    final sites = _records(sitesResponse);
    if (sites.isEmpty) {
      throw StateError('Omada controller is unreachable.');
    }
    final siteId = _value(sites.first, const ['id', 'siteId', 'site_id']);
    if (siteId == null || siteId.isEmpty) {
      throw unsupportedVendorSnapshot(router);
    }
    final devices = _records(
      await _request(router, '/openapi/v1/sites/$siteId/devices'),
    );
    if (devices.isEmpty) throw unsupportedVendorSnapshot(router);
    final primary = devices.first;
    final uptime = _number(primary, const [
      'uptime',
      'uptimeSeconds',
      'uptime_seconds',
    ]);
    return RouterOsRouterSnapshot(
      identity:
          _value(primary, const ['name', 'deviceName', 'hostname', 'id']) ??
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
            _value(primary, const ['model', 'modelName', 'deviceModel']) ?? '',
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
        for (final device in devices)
          RouterOsInterface(
            name: _value(device, const ['name', 'deviceName', 'id']) ?? '',
            type: _value(device, const ['type', 'deviceType', 'model']) ?? '',
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

  Future<Map<String, dynamic>> _request(
    RouterEntity router,
    String path,
  ) async {
    final credentials = await _credentialStore?.read(router.id);
    return _http.sendRequest(
      router: router,
      path: path,
      method: 'GET',
      token: credentials?.accessToken,
      username: credentials?.username ?? router.username,
      password: credentials?.password,
    );
  }

  List<Map<String, dynamic>> _records(Map<String, dynamic> response) {
    dynamic value =
        response['data'] ??
        response['items'] ??
        response['sites'] ??
        response['devices'];
    if (value is Map) {
      value =
          value['data'] ??
          value['items'] ??
          value['sites'] ??
          value['devices'] ??
          value['list'];
    }
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  String? _value(Map<String, dynamic> record, List<String> keys) {
    for (final key in keys) {
      final value = record[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  num _number(Map<String, dynamic> record, List<String> keys) {
    for (final key in keys) {
      final value = record[key];
      if (value is num) return value;
      final parsed = num.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return 0;
  }

  bool _isOnline(Map<String, dynamic> record) {
    final status = _value(record, const [
      'status',
      'state',
      'connectionState',
      'connection_state',
    ]);
    return record['connected'] == true ||
        record['isConnected'] == true ||
        status?.toLowerCase() == 'online' ||
        status?.toLowerCase() == 'connected';
  }

  String _formatUptime(int seconds) {
    if (seconds <= 0) return '';
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remaining = seconds % 60;
    return '${days}d ${hours}h ${minutes}m ${remaining}s';
  }
}
