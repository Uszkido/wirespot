import '../../../core/api/routeros_api_exception.dart';
import '../../../core/api/routeros_api_response.dart';
import '../../../core/api/routeros_models.dart';
import '../domain/entities/router_entity.dart';
import '../domain/services/router_connector.dart';

class PlannedRouterConnector implements RouterConnector {
  const PlannedRouterConnector(this.vendor);

  @override
  final RouterVendor vendor;

  @override
  Future<bool> testConnection(RouterEntity router) async {
    throw _unsupported(router);
  }

  @override
  Future<RouterOsApiResponse> execute(
    RouterEntity router,
    String command, {
    Map<String, String> attributes = const {},
    List<String> queries = const [],
  }) async {
    throw _unsupported(router);
  }

  @override
  Future<RouterOsRouterSnapshot> getSnapshot(RouterEntity router) async {
    throw _unsupported(router);
  }

  RouterOsApiException _unsupported(RouterEntity router) {
    return RouterOsApiException(
      '${router.vendor.label} is saved as a planned connector. '
      'WireSpot cannot manage it until this brand integration is implemented.',
      category: 'unsupported_vendor',
    );
  }
}
