import '../../../../core/storage/router_credentials.dart';
import '../entities/router_entity.dart';
import '../entities/router_group_entity.dart';

abstract interface class RouterRepository {
  Stream<List<RouterEntity>> watchRouters();

  Future<List<RouterEntity>> getRouters();

  Future<RouterEntity?> getRouter(String id);

  Future<void> saveRouter(
    RouterEntity router, {
    RouterCredentials? credentials,
  });

  Future<void> deleteRouter(String id);

  Future<void> saveGroup(RouterGroupEntity group);

  Future<List<RouterGroupEntity>> getGroups();
}
