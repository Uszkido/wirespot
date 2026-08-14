enum HotspotDeploymentStatus { succeeded, failed }

class HotspotDeploymentEntity {
  const HotspotDeploymentEntity({
    required this.id,
    required this.routerId,
    required this.routerName,
    required this.preset,
    required this.serverName,
    required this.profileName,
    required this.serverAction,
    required this.profileAction,
    required this.status,
    required this.deployedAt,
    this.message,
  });

  final String id;
  final String routerId;
  final String routerName;
  final String preset;
  final String serverName;
  final String profileName;
  final String serverAction;
  final String profileAction;
  final HotspotDeploymentStatus status;
  final DateTime deployedAt;
  final String? message;
}
