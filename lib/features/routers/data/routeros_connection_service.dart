import '../../../core/api/routeros_api_exception.dart';
import '../../../core/api/routeros_api_response.dart';
import '../../../core/api/routeros_client_factory.dart';
import '../../../core/api/routeros_models.dart';
import '../../../core/storage/router_credential_store.dart';
import '../../../core/vpn/vpn_status_service.dart';
import '../domain/entities/router_entity.dart';
import '../domain/services/router_connection_service.dart';

class RouterOsConnectionService implements RouterConnectionService {
  const RouterOsConnectionService({
    required RouterOsClientFactory clientFactory,
    required RouterCredentialStore credentialStore,
    required VpnStatusService vpnStatusService,
  }) : _clientFactory = clientFactory,
       _credentialStore = credentialStore,
       _vpnStatusService = vpnStatusService;

  final RouterOsClientFactory _clientFactory;
  final RouterCredentialStore _credentialStore;
  final VpnStatusService _vpnStatusService;

  @override
  Future<bool> testConnection(RouterEntity router) async {
    try {
      await execute(router, '/system/identity/print');
      return true;
    } on RouterOsApiException {
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
    try {
      return await _executeOnce(
        router,
        command,
        attributes: attributes,
        queries: queries,
      );
    } on RouterOsConnectionException {
      return _executeOnce(
        router,
        command,
        attributes: attributes,
        queries: queries,
      );
    }
  }

  Future<RouterOsApiResponse> _executeOnce(
    RouterEntity router,
    String command, {
    required Map<String, String> attributes,
    required List<String> queries,
  }) async {
    if (router.requireVpn) {
      await _ensureVpnIsConnected();
    }
    final credentials = await _credentialStore.read(router.id);
    if (credentials == null) {
      throw const RouterOsAuthenticationException(
        'Router credentials are not available in secure storage.',
      );
    }

    final client = _clientFactory.create(
      host: router.host,
      port: router.apiPort,
      useSsl: router.useSsl,
    );

    try {
      await client.login(
        username: credentials.username,
        password: credentials.password,
      );
      return await client.execute(
        command,
        attributes: attributes,
        queries: queries,
      );
    } finally {
      await client.disconnect();
    }
  }

  @override
  Future<RouterOsRouterSnapshot> getSnapshot(RouterEntity router) async {
    final identityResponse = await execute(router, '/system/identity/print');
    final resourceResponse = await execute(router, '/system/resource/print');
    final interfaceResponse = await execute(router, '/interface/print');

    final resourceRecords = resourceResponse.records;
    if (resourceRecords.isEmpty) {
      throw const RouterOsApiException('Router resource response was empty.');
    }

    return RouterOsRouterSnapshot(
      identity: identityResponse.records.isEmpty
          ? ''
          : identityResponse.records.first['name'] ?? '',
      resource: RouterOsSystemResource.fromApi(resourceRecords.first),
      interfaces: interfaceResponse.records
          .map(RouterOsInterface.fromApi)
          .where((interface) => interface.name.isNotEmpty)
          .toList(),
    );
  }

  Future<void> _ensureVpnIsConnected() async {
    final vpnStatus = await _vpnStatusService.currentStatus();
    if (!vpnStatus.isConnected) {
      throw const RouterOsVpnRequiredException(
        'WireGuard VPN must be connected before RouterOS API communication.',
      );
    }
  }
}
