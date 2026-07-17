import '../../../core/api/routeros_models.dart';
import '../../routers/domain/entities/router_entity.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.router,
    this.routerSnapshot,
    this.todaySalesMinor = 0,
    this.todaySalesCurrency = 'NGN',
    this.onlineUsers = 0,
    this.activeSessions = 0,
  });

  final RouterEntity router;
  final RouterOsRouterSnapshot? routerSnapshot;
  final int todaySalesMinor;
  final String todaySalesCurrency;
  final int onlineUsers;
  final int activeSessions;

  String get routerName {
    final identity = routerSnapshot?.identity;
    if (identity != null && identity.isNotEmpty) {
      return identity;
    }
    return router.name;
  }
}
