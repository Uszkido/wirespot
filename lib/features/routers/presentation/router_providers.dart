import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/di/providers.dart';
import '../domain/entities/router_entity.dart';
import '../domain/entities/router_group_entity.dart';

final routersProvider = StreamProvider.autoDispose<List<RouterEntity>>((ref) {
  return ref.watch(routerRepositoryProvider).watchRouters();
});

/// Last operator-requested fleet connection results. Router screens never make
/// network calls merely by rendering; operators explicitly run the fleet check.
final routerConnectionStatesProvider = StateProvider<Map<String, bool>>(
  (ref) => const {},
);

/// Null means the fleet view includes every site and ungrouped router.
final selectedRouterGroupIdProvider = StateProvider<String?>((ref) => null);

final routerByIdProvider = FutureProvider.autoDispose
    .family<RouterEntity?, String>((ref, routerId) {
      return ref.watch(routerRepositoryProvider).getRouter(routerId);
    });

final routerGroupsProvider =
    FutureProvider.autoDispose<List<RouterGroupEntity>>((ref) {
      return ref.watch(routerRepositoryProvider).getGroups();
    });
