import '../../routers/domain/entities/router_entity.dart';
import '../../routers/domain/services/router_connection_service.dart';
import '../domain/entities/hotspot_active_session_entity.dart';
import '../domain/entities/hotspot_cookie_entity.dart';
import '../domain/entities/hotspot_ip_binding_entity.dart';
import '../domain/entities/hotspot_ip_binding_input.dart';
import '../domain/entities/hotspot_profile_input.dart';
import '../domain/entities/hotspot_queue_entity.dart';
import '../domain/entities/hotspot_setup_input.dart';
import '../domain/entities/hotspot_user_entity.dart';
import '../domain/entities/hotspot_user_input.dart';
import '../domain/entities/hotspot_user_profile_entity.dart';
import '../domain/services/hotspot_service.dart';

class RouterOsHotspotService implements HotspotService {
  const RouterOsHotspotService(this._routerConnectionService);

  final RouterConnectionService _routerConnectionService;

  @override
  Future<void> setupHotspot(
    RouterEntity router,
    HotspotSetupInput input,
  ) async {
    _validateSetupInput(input);
    await _provisionNetwork(router, input);
    final existingProfile = await _routerConnectionService.execute(
      router,
      '/ip/hotspot/profile/print',
      queries: ['=name=${input.serverProfileName.trim()}'],
    );
    if (existingProfile.isEmpty) {
      await _routerConnectionService.execute(
        router,
        '/ip/hotspot/profile/add',
        attributes: input.toServerProfileAttributes(),
      );
    }
    final existingServer = await _routerConnectionService.execute(
      router,
      '/ip/hotspot/print',
      queries: ['=name=${input.serverName.trim()}'],
    );
    if (existingServer.isEmpty) {
      await _routerConnectionService.execute(
        router,
        '/ip/hotspot/add',
        attributes: input.toServerAttributes(),
      );
    } else {
      final serverId = existingServer.records.first['.id'];
      if (serverId == null || serverId.trim().isEmpty) {
        throw StateError('RouterOS returned a hotspot server without an id.');
      }
      await _routerConnectionService.execute(
        router,
        '/ip/hotspot/set',
        attributes: {'.id': serverId, ...input.toServerAttributes()},
      );
    }
  }

  Future<void> _provisionNetwork(
    RouterEntity router,
    HotspotSetupInput input,
  ) async {
    final addressAttributes = input.toAddressAttributes();
    if (addressAttributes != null) {
      await _addWhenMissing(
        router,
        printCommand: '/ip/address/print',
        addCommand: '/ip/address/add',
        queries: ['=address=${addressAttributes['address']}'],
        attributes: addressAttributes,
      );
    }

    final poolAttributes = input.toPoolAttributes();
    if (poolAttributes != null) {
      await _addWhenMissing(
        router,
        printCommand: '/ip/pool/print',
        addCommand: '/ip/pool/add',
        queries: ['=name=${poolAttributes['name']}'],
        attributes: poolAttributes,
      );
    }

    final dhcpNetworkAttributes = input.toDhcpNetworkAttributes();
    if (dhcpNetworkAttributes != null) {
      await _addWhenMissing(
        router,
        printCommand: '/ip/dhcp-server/network/print',
        addCommand: '/ip/dhcp-server/network/add',
        queries: ['=address=${dhcpNetworkAttributes['address']}'],
        attributes: dhcpNetworkAttributes,
      );
    }

    final dhcpServerAttributes = input.toDhcpServerAttributes();
    if (dhcpServerAttributes != null) {
      await _addWhenMissing(
        router,
        printCommand: '/ip/dhcp-server/print',
        addCommand: '/ip/dhcp-server/add',
        queries: ['=name=${dhcpServerAttributes['name']}'],
        attributes: dhcpServerAttributes,
      );
    }

    final natAttributes = input.toNatMasqueradeAttributes();
    if (natAttributes != null) {
      await _addWhenMissing(
        router,
        printCommand: '/ip/firewall/nat/print',
        addCommand: '/ip/firewall/nat/add',
        queries: ['=comment=${natAttributes['comment']}'],
        attributes: natAttributes,
      );
    }
  }

  Future<void> _addWhenMissing(
    RouterEntity router, {
    required String printCommand,
    required String addCommand,
    required List<String> queries,
    required Map<String, String> attributes,
  }) async {
    final existing = await _routerConnectionService.execute(
      router,
      printCommand,
      queries: queries,
    );
    if (existing.isEmpty) {
      await _routerConnectionService.execute(
        router,
        addCommand,
        attributes: attributes,
      );
    }
  }

  @override
  Future<List<HotspotUserEntity>> getUsers(RouterEntity router) async {
    final response = await _routerConnectionService.execute(
      router,
      '/ip/hotspot/user/print',
    );
    return response.records
        .map(HotspotUserEntity.fromRouterOs)
        .where((user) => user.id.isNotEmpty)
        .toList();
  }

  @override
  Future<void> createUser(RouterEntity router, HotspotUserInput input) async {
    _validateUserInput(input);
    await _routerConnectionService.execute(
      router,
      '/ip/hotspot/user/add',
      attributes: input.toRouterOsAttributes(),
    );
  }

  @override
  Future<void> updateUser(
    RouterEntity router,
    String userId,
    HotspotUserInput input,
  ) async {
    _validateRouterOsId(userId, label: 'User id');
    _validateUserInput(input);
    await _routerConnectionService.execute(
      router,
      '/ip/hotspot/user/set',
      attributes: {'.id': userId, ...input.toRouterOsAttributes()},
    );
  }

  @override
  Future<void> deleteUser(RouterEntity router, String userId) async {
    _validateRouterOsId(userId, label: 'User id');
    await _routerConnectionService.execute(
      router,
      '/ip/hotspot/user/remove',
      attributes: {'.id': userId},
    );
  }

  @override
  Future<void> resetUserCounters(RouterEntity router, String userId) async {
    _validateRouterOsId(userId, label: 'User id');
    await _routerConnectionService.execute(
      router,
      '/ip/hotspot/user/reset-counters',
      attributes: {'.id': userId},
    );
  }

  @override
  Future<List<HotspotUserProfileEntity>> getProfiles(
    RouterEntity router,
  ) async {
    final response = await _routerConnectionService.execute(
      router,
      '/ip/hotspot/user/profile/print',
    );
    return response.records
        .map(HotspotUserProfileEntity.fromRouterOs)
        .where((profile) => profile.id.isNotEmpty)
        .toList();
  }

  @override
  Future<void> createProfile(
    RouterEntity router,
    HotspotProfileInput input,
  ) async {
    _validateProfileInput(input);
    await _routerConnectionService.execute(
      router,
      '/ip/hotspot/user/profile/add',
      attributes: input.toRouterOsAttributes(),
    );
  }

  @override
  Future<void> updateProfile(
    RouterEntity router,
    String profileId,
    HotspotProfileInput input,
  ) async {
    _validateRouterOsId(profileId, label: 'Profile id');
    _validateProfileInput(input);
    await _routerConnectionService.execute(
      router,
      '/ip/hotspot/user/profile/set',
      attributes: {'.id': profileId, ...input.toRouterOsAttributes()},
    );
  }

  @override
  Future<void> deleteProfile(RouterEntity router, String profileId) async {
    _validateRouterOsId(profileId, label: 'Profile id');
    await _routerConnectionService.execute(
      router,
      '/ip/hotspot/user/profile/remove',
      attributes: {'.id': profileId},
    );
  }

  @override
  Future<List<HotspotActiveSessionEntity>> getActiveSessions(
    RouterEntity router,
  ) async {
    final response = await _routerConnectionService.execute(
      router,
      '/ip/hotspot/active/print',
    );
    return response.records
        .map(HotspotActiveSessionEntity.fromRouterOs)
        .where((session) => session.id.isNotEmpty)
        .toList();
  }

  @override
  Future<void> disconnectSession(RouterEntity router, String sessionId) async {
    _validateRouterOsId(sessionId, label: 'Session id');
    await _routerConnectionService.execute(
      router,
      '/ip/hotspot/active/remove',
      attributes: {'.id': sessionId},
    );
  }

  @override
  Future<List<HotspotCookieEntity>> getCookies(RouterEntity router) async {
    final response = await _routerConnectionService.execute(
      router,
      '/ip/hotspot/cookie/print',
    );
    return response.records
        .map(HotspotCookieEntity.fromRouterOs)
        .where((cookie) => cookie.id.isNotEmpty)
        .toList();
  }

  @override
  Future<void> deleteCookie(RouterEntity router, String cookieId) async {
    _validateRouterOsId(cookieId, label: 'Cookie id');
    await _routerConnectionService.execute(
      router,
      '/ip/hotspot/cookie/remove',
      attributes: {'.id': cookieId},
    );
  }

  @override
  Future<List<HotspotIpBindingEntity>> getIpBindings(
    RouterEntity router,
  ) async {
    final response = await _routerConnectionService.execute(
      router,
      '/ip/hotspot/ip-binding/print',
    );
    return response.records
        .map(HotspotIpBindingEntity.fromRouterOs)
        .where((binding) => binding.id.isNotEmpty)
        .toList();
  }

  @override
  Future<void> createIpBinding(
    RouterEntity router,
    HotspotIpBindingInput input,
  ) async {
    _validateIpBindingInput(input);
    await _routerConnectionService.execute(
      router,
      '/ip/hotspot/ip-binding/add',
      attributes: input.toRouterOsAttributes(),
    );
  }

  @override
  Future<void> updateIpBinding(
    RouterEntity router,
    String bindingId,
    HotspotIpBindingInput input,
  ) async {
    _validateRouterOsId(bindingId, label: 'IP binding id');
    _validateIpBindingInput(input);
    await _routerConnectionService.execute(
      router,
      '/ip/hotspot/ip-binding/set',
      attributes: {'.id': bindingId, ...input.toRouterOsAttributes()},
    );
  }

  @override
  Future<void> deleteIpBinding(RouterEntity router, String bindingId) async {
    _validateRouterOsId(bindingId, label: 'IP binding id');
    await _routerConnectionService.execute(
      router,
      '/ip/hotspot/ip-binding/remove',
      attributes: {'.id': bindingId},
    );
  }

  @override
  Future<List<HotspotQueueEntity>> getQueues(RouterEntity router) async {
    final response = await _routerConnectionService.execute(
      router,
      '/queue/simple/print',
    );
    return response.records
        .map(HotspotQueueEntity.fromRouterOs)
        .where((queue) => queue.id.isNotEmpty)
        .toList();
  }

  void _validateUserInput(HotspotUserInput input) {
    if (input.username.trim().isEmpty) {
      throw ArgumentError.value(input.username, 'username', 'Required');
    }
  }

  void _validateProfileInput(HotspotProfileInput input) {
    if (input.name.trim().isEmpty) {
      throw ArgumentError.value(input.name, 'name', 'Required');
    }
  }

  void _validateSetupInput(HotspotSetupInput input) {
    if (input.serverName.trim().isEmpty) {
      throw ArgumentError.value(input.serverName, 'serverName', 'Required');
    }
    if (input.interfaceName.trim().isEmpty) {
      throw ArgumentError.value(
        input.interfaceName,
        'interfaceName',
        'Required',
      );
    }
    if (input.serverProfileName.trim().isEmpty) {
      throw ArgumentError.value(
        input.serverProfileName,
        'serverProfileName',
        'Required',
      );
    }
  }

  void _validateIpBindingInput(HotspotIpBindingInput input) {
    final hasAddress =
        input.address != null && input.address!.trim().isNotEmpty;
    final hasMacAddress =
        input.macAddress != null && input.macAddress!.trim().isNotEmpty;
    if (!hasAddress && !hasMacAddress) {
      throw ArgumentError(
        'Hotspot IP binding requires an address or MAC address.',
      );
    }
    if (input.type.trim().isEmpty) {
      throw ArgumentError.value(input.type, 'type', 'Required');
    }
  }

  void _validateRouterOsId(String id, {required String label}) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, label, 'Required');
    }
  }
}
