import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/api/routeros_models.dart';
import '../../../core/di/providers.dart';
import '../../routers/domain/entities/router_entity.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/dashboard_snapshot.dart';

final selectedRouterIdProvider = StateProvider<String?>((ref) => null);

final dashboardSnapshotProvider =
    FutureProvider.autoDispose<DashboardSnapshot?>((ref) async {
      final routers = await ref.watch(routerRepositoryProvider).getRouters();
      if (routers.isEmpty) {
        return null;
      }

      final selectedRouterId = ref.watch(selectedRouterIdProvider);
      final router = routers.firstWhere(
        (item) => item.id == selectedRouterId,
        orElse: () => routers.first,
      );

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final sales = await ref
          .watch(reportRepositoryProvider)
          .getSales(routerId: router.id, from: startOfDay, to: today);
      final defaultCurrency =
          ref.watch(appSettingsProvider).asData?.value.currencyCode ?? 'NGN';

      RouterOsRouterSnapshot? snapshot;
      try {
        snapshot = await ref
            .watch(routerConnectionServiceProvider)
            .getSnapshot(router);
      } on Object {
        snapshot = null;
      }

      final activeSessions = await _activeHotspotClientCount(ref, router);

      return DashboardSnapshot(
        router: router,
        routerSnapshot: snapshot,
        onlineUsers: activeSessions,
        activeSessions: activeSessions,
        todaySalesCurrency: sales.isEmpty
            ? defaultCurrency
            : sales.first.currency,
        todaySalesMinor: sales.fold<int>(
          0,
          (total, sale) => total + sale.amountMinor,
        ),
      );
    });

Future<int> _activeHotspotClientCount(Ref ref, RouterEntity router) async {
  try {
    final sessions = await ref
        .watch(hotspotServiceProvider)
        .getActiveSessions(router);
    if (sessions.isNotEmpty) {
      return sessions.length;
    }
  } on Object {
    // Fall through to the host table fallback below.
  }

  try {
    final response = await ref
        .watch(routerConnectionServiceProvider)
        .execute(router, '/ip/hotspot/host/print');
    return response.records.where((record) {
      return record['authorized'] == 'true' || record['bypassed'] == 'true';
    }).length;
  } on Object {
    return 0;
  }
}
