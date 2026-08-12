import '../entities/router_entity.dart';
import 'router_connection_service.dart';

class RouterConnectionResult {
  const RouterConnectionResult({
    required this.router,
    required this.isConnected,
  });

  final RouterEntity router;
  final bool isConnected;
}

/// Runs independent router connection checks concurrently. Each connector owns
/// its request lifecycle, so selecting one dashboard router never prevents
/// WireSpot from checking another router at the same time.
class RouterFleetConnectionService {
  const RouterFleetConnectionService(this._routerConnectionService);

  final RouterConnectionService _routerConnectionService;

  Future<List<RouterConnectionResult>> testConnections(
    Iterable<RouterEntity> routers,
  ) {
    return Future.wait(
      routers.map((router) async {
        try {
          final isConnected = await _routerConnectionService.testConnection(
            router,
          );
          return RouterConnectionResult(
            router: router,
            isConnected: isConnected,
          );
        } on Object {
          return RouterConnectionResult(router: router, isConnected: false);
        }
      }),
    );
  }
}
