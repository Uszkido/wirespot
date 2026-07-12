import '../../../routers/domain/entities/router_entity.dart';
import '../entities/hotspot_active_session_entity.dart';
import '../entities/hotspot_cookie_entity.dart';
import '../entities/hotspot_ip_binding_entity.dart';
import '../entities/hotspot_ip_binding_input.dart';
import '../entities/hotspot_profile_input.dart';
import '../entities/hotspot_queue_entity.dart';
import '../entities/hotspot_setup_input.dart';
import '../entities/hotspot_user_entity.dart';
import '../entities/hotspot_user_input.dart';
import '../entities/hotspot_user_profile_entity.dart';

abstract interface class HotspotService {
  Future<void> setupHotspot(RouterEntity router, HotspotSetupInput input);

  Future<List<HotspotUserEntity>> getUsers(RouterEntity router);

  Future<void> createUser(RouterEntity router, HotspotUserInput input);

  Future<void> updateUser(
    RouterEntity router,
    String userId,
    HotspotUserInput input,
  );

  Future<void> deleteUser(RouterEntity router, String userId);

  Future<void> resetUserCounters(RouterEntity router, String userId);

  Future<List<HotspotUserProfileEntity>> getProfiles(RouterEntity router);

  Future<void> createProfile(RouterEntity router, HotspotProfileInput input);

  Future<void> updateProfile(
    RouterEntity router,
    String profileId,
    HotspotProfileInput input,
  );

  Future<void> deleteProfile(RouterEntity router, String profileId);

  Future<List<HotspotActiveSessionEntity>> getActiveSessions(
    RouterEntity router,
  );

  Future<void> disconnectSession(RouterEntity router, String sessionId);

  Future<List<HotspotCookieEntity>> getCookies(RouterEntity router);

  Future<void> deleteCookie(RouterEntity router, String cookieId);

  Future<List<HotspotIpBindingEntity>> getIpBindings(RouterEntity router);

  Future<void> createIpBinding(
    RouterEntity router,
    HotspotIpBindingInput input,
  );

  Future<void> updateIpBinding(
    RouterEntity router,
    String bindingId,
    HotspotIpBindingInput input,
  );

  Future<void> deleteIpBinding(RouterEntity router, String bindingId);

  Future<List<HotspotQueueEntity>> getQueues(RouterEntity router);
}
