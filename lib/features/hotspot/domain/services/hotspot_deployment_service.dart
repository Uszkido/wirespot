import 'package:uuid/uuid.dart';

import '../../../cloud/domain/services/cloud_sync_service.dart';
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
    CloudSyncService? cloudSyncService,
    Uuid uuid = const Uuid(),
  }) : _hotspotService = hotspotService,
       _repository = repository,
       _cloudSyncService = cloudSyncService,
       _uuid = uuid;

  final HotspotService _hotspotService;
  final HotspotDeploymentRepository _repository;
  final CloudSyncService? _cloudSyncService;
  final Uuid _uuid;

  Future<void> deploy({
    required RouterEntity router,
    required HotspotSetupPreset preset,
    required HotspotSetupInput input,
    required HotspotSetupInspection inspection,
  }) async {
    try {
      await _hotspotService.setupHotspot(router, input);
      final entity = HotspotDeploymentEntity(
        id: _uuid.v4(),
        routerId: router.id,
        routerName: router.name,
        preset: preset.label,
        serverName: input.serverName,
        profileName: input.serverProfileName,
        serverAction: inspection.serverAction,
        profileAction: inspection.profileAction,
        status: HotspotDeploymentStatus.succeeded,
        deployedAt: DateTime.now(),
      );
      await _repository.save(entity);
      await _cloudSyncService?.queueUpsert(
        resourceType: 'hotspot_deployment',
        resourceId: entity.id,
        payload: {
          'id': entity.id,
          'routerId': entity.routerId,
          'routerName': entity.routerName,
          'preset': entity.preset,
          'serverName': entity.serverName,
          'profileName': entity.profileName,
          'status': entity.status.name,
          'deployedAt': entity.deployedAt.toUtc().toIso8601String(),
        },
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
