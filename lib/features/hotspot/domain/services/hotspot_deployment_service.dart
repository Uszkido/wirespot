import 'package:uuid/uuid.dart';

import '../../../routers/domain/entities/router_entity.dart';
import '../entities/hotspot_deployment_entity.dart';
import '../entities/hotspot_setup_inspection.dart';
import '../entities/hotspot_setup_input.dart';
import '../entities/hotspot_setup_preset.dart';
import '../repositories/hotspot_deployment_repository.dart';
import 'hotspot_service.dart';

class HotspotDeploymentService {
  HotspotDeploymentService({
    required HotspotService hotspotService,
    required HotspotDeploymentRepository repository,
    Uuid uuid = const Uuid(),
  }) : _hotspotService = hotspotService,
       _repository = repository,
       _uuid = uuid;

  final HotspotService _hotspotService;
  final HotspotDeploymentRepository _repository;
  final Uuid _uuid;

  Future<void> deploy({
    required RouterEntity router,
    required HotspotSetupPreset preset,
    required HotspotSetupInput input,
    required HotspotSetupInspection inspection,
  }) async {
    try {
      await _hotspotService.setupHotspot(router, input);
      await _save(
        router,
        preset,
        input,
        inspection,
        HotspotDeploymentStatus.succeeded,
      );
    } on Object catch (error) {
      await _save(
        router,
        preset,
        input,
        inspection,
        HotspotDeploymentStatus.failed,
        error.toString(),
      );
      rethrow;
    }
  }

  Future<void> _save(
    RouterEntity router,
    HotspotSetupPreset preset,
    HotspotSetupInput input,
    HotspotSetupInspection inspection,
    HotspotDeploymentStatus status, [
    String? message,
  ]) => _repository.save(
    HotspotDeploymentEntity(
      id: _uuid.v4(),
      routerId: router.id,
      routerName: router.name,
      preset: preset.label,
      serverName: input.serverName,
      profileName: input.serverProfileName,
      serverAction: inspection.serverAction,
      profileAction: inspection.profileAction,
      status: status,
      message: message,
      deployedAt: DateTime.now(),
    ),
  );
}
