import '../../../core/api/routeros_api_response.dart';
import '../../../core/api/routeros_models.dart';
import '../../../core/api/vendor_http_client.dart';
import '../../../core/storage/router_credential_store.dart';
import '../domain/entities/router_entity.dart';
import '../domain/services/router_connector.dart';
import 'vendor_mutation_support.dart';

/// Omada Controller connection and authentication probe.
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
      final credentials = await _credentialStore?.read(router.id);
      final result = await _http.sendRequest(
        router: router,
        path: '/api/info',
        method: 'GET',
        username: credentials?.username ?? router.username,
        password: credentials?.password,
      );
      return result.isNotEmpty && result['status'] != 'error';
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
      throw StateError('Omada controller is unreachable.');
    }
    throw unsupportedVendorSnapshot(router);
  }
}
