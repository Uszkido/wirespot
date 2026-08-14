import '../entities/hotspot_deployment_entity.dart';

abstract interface class HotspotDeploymentRepository {
  Future<void> save(HotspotDeploymentEntity deployment);
  Future<List<HotspotDeploymentEntity>> getHistory({String? routerId});
}
