import '../../../core/api/routeros_api_exception.dart';
import '../../../core/api/routeros_api_response.dart';
import '../../../core/api/routeros_models.dart';
import '../../../core/api/vendor_http_client.dart';
import '../../../core/storage/router_credential_store.dart';
import '../domain/entities/router_entity.dart';
import '../domain/services/router_connector.dart';
import 'vendor_mutation_support.dart';

/// UniFi Network Controller connection and dashboard connector.
///
/// Reboot requires explicit controller site and device IDs; the connector does
/// not guess a target from discovery results.
class UniFiConnectionService implements RouterConnector {
  UniFiConnectionService({
    VendorHttpClient? httpClient,
    RouterCredentialStore? credentialStore,
  }) : _http = httpClient ?? VendorHttpClient(),
       _credentialStore = credentialStore;

  final VendorHttpClient _http;
  final RouterCredentialStore? _credentialStore;

  @override
  RouterVendor get vendor => RouterVendor.ubiquitiUniFi;

  @override
  Future<bool> testConnection(RouterEntity router) async {
    try {
      final result = await _sites(router);
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
    if (command == '/system/reboot') {
      final siteId = attributes['siteId']?.trim();
      final deviceId = attributes['deviceId']?.trim();
      if (siteId == null ||
          siteId.isEmpty ||
          deviceId == null ||
          deviceId.isEmpty) {
        throw RouterOsApiException(
          'UniFi reboot requires explicit siteId and deviceId attributes.',
          category: 'invalid_configuration',
        );
      }
      final response = await _http.sendRequest(
        router: router,
        path:
            '/proxy/network/integration/v1/sites/${Uri.encodeComponent(siteId)}/devices/${Uri.encodeComponent(deviceId)}/actions',
        method: 'POST',
        token: await _token(router),
        username: await _username(router),
        password: await _password(router),
        data: const {'action': 'RESTART'},
      );
      final status = response['status']?.toString().toLowerCase();
      final code = response['code'];
      if (status == 'error' || (code is num && code >= 400)) {
        throw RouterOsApiException(
          response['message']?.toString() ?? 'UniFi reboot request failed.',
          category: 'remote_command_failed',
        );
      }
      return const RouterOsApiResponse(
        records: [
          {'status': 'reboot-requested', 'vendor': 'unifi'},
        ],
      );
    }
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
    final sitesResponse = await _sites(router);
    final sites = _records(sitesResponse);
    if (sites.isEmpty) {
      throw StateError('UniFi controller is unreachable.');
    }
    final siteId = _value(sites.first, const ['id', 'siteId', '_id']);
    if (siteId == null || siteId.isEmpty) {
      throw unsupportedVendorSnapshot(router);
    }
    final devicesResponse = await _http.sendRequest(
      router: router,
      path: '/proxy/network/integration/v1/sites/$siteId/devices',
      method: 'GET',
      token: await _token(router),
      username: await _username(router),
      password: await _password(router),
    );
    final devices = _records(devicesResponse);
    if (devices.isEmpty) throw unsupportedVendorSnapshot(router);
    final primary = devices.first;
    final cpu = _number(primary, const ['cpuUtilization', 'cpuLoad']);
    final freeMemory = _number(primary, const ['freeMemory', 'memoryFree']);
    final totalMemory = _number(primary, const ['totalMemory', 'memoryTotal']);
    return RouterOsRouterSnapshot(
      identity:
          _value(primary, const ['name', 'displayName', 'model']) ??
          router.name,
      resource: RouterOsSystemResource(
        uptime: _formatUptime(
          _number(primary, const ['uptime', 'uptimeSeconds']).toInt(),
        ),
        version: _value(primary, const ['version', 'firmwareVersion']) ?? '',
        boardName: _value(primary, const ['model', 'modelName']) ?? '',
        cpuLoad: cpu.clamp(0, 100).toInt(),
        freeMemory: freeMemory.toInt(),
        totalMemory: totalMemory.toInt(),
      ),
      interfaces: [
        for (final device in devices)
          RouterOsInterface(
            name: _value(device, const ['name', 'displayName', 'id']) ?? '',
            type: _value(device, const ['type', 'deviceType', 'model']) ?? '',
            running: _isOnline(device),
            disabled: false,
            macAddress: _value(device, const ['macAddress', 'mac']),
          ),
      ],
    );
  }

  Future<Map<String, dynamic>> _sites(RouterEntity router) async {
    return _http.sendRequest(
      router: router,
      path: '/proxy/network/integration/v1/sites',
      method: 'GET',
      token: await _token(router),
      username: await _username(router),
      password: await _password(router),
    );
  }

  Future<String?> _username(RouterEntity router) async =>
      (await _credentialStore?.read(router.id))?.username ?? router.username;

  Future<String?> _password(RouterEntity router) async =>
      (await _credentialStore?.read(router.id))?.password;

  Future<String?> _token(RouterEntity router) async =>
      (await _credentialStore?.read(router.id))?.accessToken;

  List<Map<String, dynamic>> _records(Map<String, dynamic> response) {
    dynamic value =
        response['data'] ??
        response['items'] ??
        response['sites'] ??
        response['devices'];
    if (value is Map) {
      value =
          value['data'] ?? value['items'] ?? value['sites'] ?? value['devices'];
    }
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
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
    final status = _value(record, const ['status', 'state', 'connectionState']);
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
