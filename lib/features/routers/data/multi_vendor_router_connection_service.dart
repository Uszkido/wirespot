import '../../../core/api/routeros_api_exception.dart';
import '../../../core/api/routeros_api_response.dart';
import '../../../core/api/routeros_models.dart';
import '../domain/entities/router_entity.dart';
import '../domain/services/router_connection_service.dart';
import '../domain/services/router_connector.dart';

class MultiVendorRouterConnectionService implements RouterConnectionService {
  MultiVendorRouterConnectionService({
    required List<RouterConnector> connectors,
  }) : _connectorsByVendor = {
         for (final connector in connectors) connector.vendor: connector,
       };

  final Map<RouterVendor, RouterConnector> _connectorsByVendor;

  @override
  Future<bool> testConnection(RouterEntity router) {
    return _connectorFor(router).testConnection(router);
  }

  @override
  Future<RouterOsApiResponse> execute(
    RouterEntity router,
    String command, {
    Map<String, String> attributes = const {},
    List<String> queries = const [],
  }) {
    return _connectorFor(
      router,
    ).execute(router, command, attributes: attributes, queries: queries);
  }

  @override
  Stream<Map<String, String>> stream(
    RouterEntity router,
    String command, {
    Map<String, String> attributes = const {},
    List<String> queries = const [],
  }) {
    return _connectorFor(
      router,
    ).stream(router, command, attributes: attributes, queries: queries);
  }

  @override
  Future<RouterOsRouterSnapshot> getSnapshot(RouterEntity router) {
    return _connectorFor(router).getSnapshot(router);
  }

  RouterConnector _connectorFor(RouterEntity router) {
    final connector = _connectorsByVendor[router.vendor];
    if (connector == null) {
      throw RouterOsApiException(
        'No connector is registered for ${router.vendor.label}.',
        category: 'unsupported_vendor',
      );
    }
    return connector;
  }
}
