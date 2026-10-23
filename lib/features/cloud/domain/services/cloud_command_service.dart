import 'package:wirespot/features/hotspot/domain/services/hotspot_service.dart';
import 'package:wirespot/features/routers/domain/repositories/router_repository.dart';
import 'package:wirespot/features/routers/domain/entities/router_entity.dart';
import 'package:wirespot/features/routers/domain/services/router_connection_service.dart';
import '../../data/cloud_api_client.dart';
import '../entities/cloud_command.dart';
import 'cloud_sync_service.dart';

class CloudCommandExecutionResult {
  const CloudCommandExecutionResult({
    required this.commandId,
    required this.type,
    required this.success,
    this.resultPayload,
    this.errorMessage,
  });

  final String commandId;
  final String type;
  final bool success;
  final Map<String, Object?>? resultPayload;
  final String? errorMessage;
}

class CloudCommandService {
  const CloudCommandService({
    required CloudApiClient apiClient,
    required RouterRepository routerRepository,
    required RouterConnectionService routerConnectionService,
    required HotspotService hotspotService,
    required CloudSyncService cloudSyncService,
  }) : _apiClient = apiClient,
       _routerRepository = routerRepository,
       _routerConnectionService = routerConnectionService,
       _hotspotService = hotspotService,
       _cloudSyncService = cloudSyncService;

  final CloudApiClient _apiClient;
  final RouterRepository _routerRepository;
  final RouterConnectionService _routerConnectionService;
  final HotspotService _hotspotService;
  final CloudSyncService _cloudSyncService;

  Future<List<CloudCommandExecutionResult>> processPendingCommands() async {
    final results = <CloudCommandExecutionResult>[];
    try {
      final pendingJson = await _apiClient.fetchPendingCommands();
      for (final raw in pendingJson) {
        final command = CloudCommand.fromJson(raw);
        final result = await _executeCommand(command);
        results.add(result);

        await _apiClient.acknowledgeCommand(
          commandId: command.id,
          status: result.success ? 'completed' : 'failed',
          resultPayload: result.resultPayload,
          errorMessage: result.errorMessage,
        );
      }
    } catch (e) {
      // Log or swallow API fetch failure when offline
    }
    return results;
  }

  Future<CloudCommandExecutionResult> _executeCommand(
    CloudCommand command,
  ) async {
    try {
      switch (command.type) {
        case 'remote_reboot':
          final routerId = command.targetResourceId;
          if (routerId != null && routerId.isNotEmpty) {
            final router = await _routerRepository.getRouter(routerId);
            if (router == null) {
              throw StateError('Target router was not found.');
            }
            if (!router.vendor.supports(RouterCapability.systemControl)) {
              throw StateError(
                '${router.vendor.label} does not support remote system control.',
              );
            }
            final rawAttributes = command.params['attributes'];
            final attributes = rawAttributes is Map
                ? rawAttributes.map(
                    (key, value) => MapEntry(key.toString(), value.toString()),
                  )
                : const <String, String>{};
            await _routerConnectionService.execute(
              router,
              '/system/reboot',
              attributes: attributes,
            );
          } else {
            throw StateError('Remote reboot requires a target router.');
          }
          return CloudCommandExecutionResult(
            commandId: command.id,
            type: command.type,
            success: true,
            resultPayload: {'action': 'rebooted', 'targetResourceId': routerId},
          );

        case 'kick_session':
          final mac = command.params['mac'] as String?;
          final routerId = command.targetResourceId;
          if (mac != null && routerId != null && routerId.isNotEmpty) {
            final router = await _routerRepository.getRouter(routerId);
            if (router == null) {
              throw StateError('Target router was not found.');
            }
            await _hotspotService.disconnectSession(router, mac);
          } else {
            throw StateError('Kick session requires a router and MAC address.');
          }
          return CloudCommandExecutionResult(
            commandId: command.id,
            type: command.type,
            success: true,
            resultPayload: {'action': 'session_removed', 'mac': mac},
          );

        case 'router_command':
          final routerId = command.targetResourceId;
          final rawCommand = command.params['command'] as String?;
          if (routerId == null ||
              routerId.isEmpty ||
              rawCommand == null ||
              rawCommand.trim().isEmpty) {
            throw StateError(
              'Router command requires a target router and command text.',
            );
          }
          final router = await _routerRepository.getRouter(routerId);
          if (router == null) throw StateError('Target router was not found.');
          final rawAttributes = command.params['attributes'];
          final attributes = rawAttributes is Map
              ? rawAttributes.map(
                  (key, value) => MapEntry(key.toString(), value.toString()),
                )
              : const <String, String>{};
          final response = await _routerConnectionService.execute(
            router,
            rawCommand.trim(),
            attributes: attributes,
          );
          return CloudCommandExecutionResult(
            commandId: command.id,
            type: command.type,
            success: true,
            resultPayload: {
              'action': 'router_command_executed',
              'records': response.records,
            },
          );

        case 'sync_pull':
          final syncCount = await _cloudSyncService.syncPending();
          return CloudCommandExecutionResult(
            commandId: command.id,
            type: command.type,
            success: true,
            resultPayload: {
              'action': 'sync_pull_executed',
              'syncedCount': syncCount,
            },
          );

        default:
          return CloudCommandExecutionResult(
            commandId: command.id,
            type: command.type,
            success: false,
            errorMessage: 'Unsupported command type: ${command.type}',
          );
      }
    } catch (e) {
      return CloudCommandExecutionResult(
        commandId: command.id,
        type: command.type,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }
}
