import '../../../core/api/routeros_api_response.dart';
import '../../../core/api/routeros_api_exception.dart';
import '../../../core/api/routeros_models.dart';
import '../../../core/api/vendor_http_client.dart';
import '../../../core/storage/router_credential_store.dart';
import '../domain/entities/router_entity.dart';
import '../domain/services/router_connector.dart';
import 'vendor_mutation_support.dart';

/// OpenWrt LuCI/ubus connector.
///
/// The connector keeps command mutation disabled because OpenWrt packages vary
/// by distribution. It does, however, read the standard `system board`,
/// `system info`, and `network.interface dump` ubus methods for a real,
/// read-only dashboard snapshot.
class OpenWrtConnectionService implements RouterConnector {
  OpenWrtConnectionService({
    VendorHttpClient? httpClient,
    RouterCredentialStore? credentialStore,
  }) : _http = httpClient ?? VendorHttpClient(),
       _credentialStore = credentialStore;

  final VendorHttpClient _http;
  final RouterCredentialStore? _credentialStore;

  @override
  RouterVendor get vendor => RouterVendor.openWrt;

  @override
  Future<bool> testConnection(RouterEntity router) async {
    try {
      final credentials = await _credentialStore?.read(router.id);
      final result = await _http.sendRequest(
        router: router,
        path: '/cgi-bin/luci',
        method: 'POST',
        data: {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'call',
          'params': ['00000000000000000000000000000000', 'system', 'board', {}],
        },
        username: credentials?.username ?? router.username,
        password: credentials?.password,
      );
      return result['status'] != 'error';
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
    if (!await testConnection(router)) {
      throw StateError('OpenWrt router is unreachable.');
    }
    final credentials = await _credentialStore?.read(router.id);
    final session = await _login(
      router,
      credentials?.username ?? router.username,
      credentials?.password,
    );
    try {
      final board = await _rpc(router, session, 'system', 'board');
      final info = await _rpc(router, session, 'system', 'info');
      final interfaces =
          await _rpc(router, session, 'network.interface', 'dump');

      final model = _string(board, const ['model', 'board_name', 'hostname']);
      final release = _map(board['release']);
      final version = _string(release, const ['version']) ??
          _string(board, const ['version', 'kernel']);
      final memory = _map(info['memory']);
      final totalMemory = _number(memory, const ['total', 'total_bytes']);
      final freeMemory = _number(memory, const ['free', 'free_bytes']);
      final load = _numberList(info['load']);
      if (model == null || version == null || totalMemory == null ||
          freeMemory == null || load.isEmpty) {
        throw unsupportedVendorSnapshot(router);
      }

      final loadValue = load.first > 100 ? load.first / 655.36 : load.first;
      final interfaceRows = _interfaceRows(interfaces);
      return RouterOsRouterSnapshot(
        identity: _string(info, const ['hostname']) ?? model,
        resource: RouterOsSystemResource(
          uptime: _formatUptime(_number(info, const ['uptime']) ?? 0),
          version: version,
          boardName: model,
          cpuLoad: loadValue.round().clamp(0, 100).toInt(),
          freeMemory: freeMemory,
          totalMemory: totalMemory,
        ),
        interfaces: interfaceRows,
      );
    } on RouterOsApiException {
      rethrow;
    } on Object {
      throw unsupportedVendorSnapshot(router);
    }
  }

  Future<String> _login(
    RouterEntity router,
    String username,
    String? password,
  ) async {
    if (username.trim().isEmpty || password == null || password.isEmpty) {
      return '00000000000000000000000000000000';
    }
    final response = await _http.sendRequest(
      router: router,
      path: '/cgi-bin/luci',
      method: 'POST',
      data: {
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'call',
        'params': [
          '00000000000000000000000000000000',
          'session',
          'login',
          [username, password, {}, 10],
        ],
      },
      username: username,
      password: password,
    );
    final result = response['result'];
    if (result is List && result.length > 1 && result[0] == 0 &&
        result[1] is Map && (result[1] as Map)['ubus_rpc_session'] != null) {
      return (result[1] as Map)['ubus_rpc_session'].toString();
    }
    throw StateError('OpenWrt ubus authentication failed.');
  }

  Future<Map<String, dynamic>> _rpc(
    RouterEntity router,
    String session,
    String object,
    String method, {
    String? argument,
  }) async {
    final response = await _http.sendRequest(
      router: router,
      path: '/cgi-bin/luci',
      method: 'POST',
      data: {
        'jsonrpc': '2.0',
        'id': DateTime.now().microsecondsSinceEpoch,
        'method': 'call',
        'params': [session, object, method, argument == null ? {} : {}],
      },
    );
    if (response['status'] == 'error') {
      throw StateError(response['message']?.toString() ?? 'OpenWrt ubus error.');
    }
    final result = response['result'];
    if (result is List && result.length > 1 && result[0] == 0 &&
        result[1] is Map) {
      return Map<String, dynamic>.from(result[1] as Map);
    }
    if (response['data'] is Map) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    throw StateError('OpenWrt ubus returned no $object.$method data.');
  }

  List<RouterOsInterface> _interfaceRows(Map<String, dynamic> payload) {
    final raw = payload['interface'] ?? payload['interfaces'] ?? payload['items'];
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((item) {
      final row = Map<String, dynamic>.from(item);
      final name = _string(row, const ['device', 'l3_device', 'interface', 'name']) ?? '';
      final up = row['up'] == true || row['up'] == 1;
      return RouterOsInterface(name: name, type: 'openwrt', running: up, disabled: false);
    }).where((item) => item.name.isNotEmpty).toList(growable: false);
  }

  Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};

  String? _string(Map<String, dynamic> value, List<String> keys) {
    for (final key in keys) {
      final item = value[key];
      if (item != null && item.toString().trim().isNotEmpty) return item.toString();
    }
    return null;
  }

  int? _number(Map<String, dynamic> value, List<String> keys) {
    for (final key in keys) {
      final item = value[key];
      if (item is num) return item.toInt();
      final parsed = int.tryParse(item?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  List<num> _numberList(dynamic value) => value is List
      ? value.whereType<num>().toList(growable: false)
      : const [];

  String _formatUptime(int seconds) {
    final duration = Duration(seconds: seconds);
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '${days}d ${hours}h ${minutes}m';
  }
}
