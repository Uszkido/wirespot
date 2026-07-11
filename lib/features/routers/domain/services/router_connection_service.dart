import '../../../../core/api/routeros_api_response.dart';
import '../../../../core/api/routeros_models.dart';
import '../entities/router_entity.dart';

abstract interface class RouterConnectionService {
  Future<bool> testConnection(RouterEntity router);

  Future<RouterOsApiResponse> execute(
    RouterEntity router,
    String command, {
    Map<String, String> attributes,
    List<String> queries,
  });

  Future<RouterOsRouterSnapshot> getSnapshot(RouterEntity router);
}
