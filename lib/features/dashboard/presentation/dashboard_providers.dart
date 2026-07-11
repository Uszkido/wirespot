import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/api/routeros_models.dart';
import '../../../core/di/providers.dart';
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
  final sales = await ref.watch(reportRepositoryProvider).getSales(
        routerId: router.id,
        from: startOfDay,
        to: today,
      );

  RouterOsRouterSnapshot? snapshot;
  try {
    snapshot = await ref.watch(routerConnectionServiceProvider).getSnapshot(router);
  } on Object {
    snapshot = null;
  }

  return DashboardSnapshot(
    router: router,
    routerSnapshot: snapshot,
    todaySalesMinor: sales.fold<int>(
      0,
      (total, sale) => total + sale.amountMinor,
    ),
  );
});
