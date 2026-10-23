import 'package:wirespot/features/hotspot/domain/services/hotspot_service.dart';
import 'package:wirespot/features/routers/domain/services/router_connection_service.dart';
import 'package:wirespot/features/routers/domain/repositories/router_repository.dart';
import '../../data/cloud_api_client.dart';
import '../entities/cloud_telemetry_frame.dart';

class CloudTelemetryService {
  const CloudTelemetryService({
    required CloudApiClient apiClient,
    required RouterRepository routerRepository,
    required HotspotService hotspotService,
    RouterConnectionService? routerConnectionService,
  }) : _apiClient = apiClient,
       _routerRepository = routerRepository,
       _hotspotService = hotspotService,
       _routerConnectionService = routerConnectionService;

  final CloudApiClient _apiClient;
  final RouterRepository _routerRepository;
  final HotspotService _hotspotService;
  final RouterConnectionService? _routerConnectionService;

  Future<int> collectAndPostTelemetry() async {
    var postedCount = 0;
    try {
      final routers = await _routerRepository.getRouters();
      if (_routerConnectionService == null) return 0;
      for (final router in routers) {
        try {
          final snapshot = await _routerConnectionService.getSnapshot(router);
          final activeSessions = await _hotspotService.getActiveSessions(
            router,
          );
          final frame = CloudTelemetryFrame(
            routerId: router.id,
            cpuLoad: snapshot.resource.cpuLoad.toDouble(),
            freeMemoryMb: _bytesToMb(snapshot.resource.freeMemory),
            totalMemoryMb: _bytesToMb(snapshot.resource.totalMemory),
            uptimeSeconds: _parseUptime(snapshot.resource.uptime),
            activeHotspotUsersCount: activeSessions.length,
            timestamp: DateTime.now(),
          );

          final success = await _apiClient.postTelemetry(frame.toJson());
          if (success) postedCount++;
        } on Object {
          // Do not publish invented values when a router is unreachable.
        }
      }
    } catch (_) {
      // Ignore network errors when offline
    }
    return postedCount;
  }

  static double _bytesToMb(int bytes) => bytes <= 0 ? 0 : bytes / (1024 * 1024);

  static int _parseUptime(String value) {
    final pattern = RegExp(
      r'(?:(\d+)w)?(?:(\d+)d)?(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?',
    );
    final match = pattern.firstMatch(value.toLowerCase());
    if (match == null) return 0;
    int part(int index) => int.tryParse(match.group(index) ?? '') ?? 0;
    return part(1) * 604800 +
        part(2) * 86400 +
        part(3) * 3600 +
        part(4) * 60 +
        part(5);
  }
}
