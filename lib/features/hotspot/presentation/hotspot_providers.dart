import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/di/providers.dart';
import '../../routers/domain/entities/router_entity.dart';
import '../domain/entities/hotspot_active_session_entity.dart';
import '../domain/entities/hotspot_cookie_entity.dart';
import '../domain/entities/hotspot_ip_binding_entity.dart';
import '../domain/entities/hotspot_queue_entity.dart';
import '../domain/entities/hotspot_user_entity.dart';
import '../domain/entities/hotspot_user_profile_entity.dart';

final selectedHotspotRouterIdProvider = StateProvider<String?>((ref) => null);

final hotspotUsersProvider = FutureProvider.autoDispose
    .family<List<HotspotUserEntity>, RouterEntity>((ref, router) {
      return ref.watch(hotspotServiceProvider).getUsers(router);
    });

final hotspotProfilesProvider = FutureProvider.autoDispose
    .family<List<HotspotUserProfileEntity>, RouterEntity>((ref, router) {
      return ref.watch(hotspotServiceProvider).getProfiles(router);
    });

final hotspotActiveSessionsProvider = FutureProvider.autoDispose
    .family<List<HotspotActiveSessionEntity>, RouterEntity>((ref, router) {
      return ref.watch(hotspotServiceProvider).getActiveSessions(router);
    });

final hotspotCookiesProvider = FutureProvider.autoDispose
    .family<List<HotspotCookieEntity>, RouterEntity>((ref, router) {
      return ref.watch(hotspotServiceProvider).getCookies(router);
    });

final hotspotIpBindingsProvider = FutureProvider.autoDispose
    .family<List<HotspotIpBindingEntity>, RouterEntity>((ref, router) {
      return ref.watch(hotspotServiceProvider).getIpBindings(router);
    });

final hotspotQueuesProvider = FutureProvider.autoDispose
    .family<List<HotspotQueueEntity>, RouterEntity>((ref, router) {
      return ref.watch(hotspotServiceProvider).getQueues(router);
    });
