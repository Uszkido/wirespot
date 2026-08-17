import '../../../routers/domain/entities/router_entity.dart';
import '../../../routers/domain/services/router_connection_service.dart';

class NetworkDiagnosticsService {
  const NetworkDiagnosticsService(this._routerConnectionService);

  final RouterConnectionService _routerConnectionService;

  Stream<Map<String, String>> ping(
    RouterEntity router,
    String address, {
    int? count,
  }) {
    return _routerConnectionService.stream(
      router,
      '/ping',
      attributes: {
        'address': address,
        if (count != null) 'count': count.toString(),
      },
    );
  }

  Stream<Map<String, String>> traceroute(RouterEntity router, String address) {
    return _routerConnectionService.stream(
      router,
      '/tool/traceroute',
      attributes: {'address': address},
    );
  }
}
