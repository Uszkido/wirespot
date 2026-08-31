import 'dart:async';

import '../storage/secure_storage_service.dart';
import 'openvpn_config_parser.dart';
import 'unified_vpn_profile.dart';
import 'vpn_protocol.dart';
import 'vpn_statistics.dart';
import 'vpn_status.dart';
import 'wireguard_config.dart';
import 'wireguard_vpn_service.dart';

abstract interface class UnifiedVpnService {
  Future<void> importProfile(UnifiedVpnProfile profile);

  Future<void> importConfigText({
    required String name,
    required String configText,
  });

  Future<void> connect(String profileId);

  Future<void> disconnect();

  Future<VpnStatus> currentStatus();

  Future<VpnStatistics> statistics();

  Future<List<String>> logs();

  Future<List<UnifiedVpnProfile>> getSavedProfiles();

  Stream<VpnStatus> watchStatus();
}

class PlatformUnifiedVpnService implements UnifiedVpnService {
  PlatformUnifiedVpnService({
    required WireGuardVpnService wireGuardService,
    required SecureStorageService secureStorage,
  }) : _wireGuardService = wireGuardService,
       _secureStorage = secureStorage;

  final WireGuardVpnService _wireGuardService;
  final SecureStorageService _secureStorage;

  static const _storagePrefix = 'unified_vpn_profile_';

  @override
  Future<void> importProfile(UnifiedVpnProfile profile) async {
    await _secureStorage.write(
      '$_storagePrefix${profile.id}',
      profile.rawConfig,
    );
    if (profile.protocol == VpnProtocol.wireGuard) {
      final parsed = WireGuardConfig.parse(
        name: profile.name,
        config: profile.rawConfig,
      );
      await _wireGuardService.importConfig(parsed);
    }
  }

  @override
  Future<void> importConfigText({
    required String name,
    required String configText,
  }) async {
    final trimmed = configText.trim();
    if (trimmed.contains('[Interface]') || trimmed.contains('[interface]')) {
      WireGuardConfig.parse(name: name, config: trimmed);
      final profile = UnifiedVpnProfile(
        id: name,
        name: name,
        protocol: VpnProtocol.wireGuard,
        rawConfig: trimmed,
        createdAt: DateTime.now(),
      );
      await importProfile(profile);
    } else {
      final ovpnConfig = OpenVpnConfig.parse(name: name, configText: trimmed);
      final profile = UnifiedVpnProfile(
        id: name,
        name: name,
        protocol: VpnProtocol.openVpn,
        rawConfig: trimmed,
        remoteHost: ovpnConfig.remoteHost,
        remotePort: ovpnConfig.remotePort,
        createdAt: DateTime.now(),
      );
      await importProfile(profile);
    }
  }

  @override
  Future<void> connect(String profileId) async {
    final profiles = await getSavedProfiles();
    final profile = profiles.firstWhere(
      (p) => p.id == profileId || p.name == profileId,
      orElse: () => UnifiedVpnProfile(
        id: profileId,
        name: profileId,
        protocol: VpnProtocol.wireGuard,
        rawConfig: '',
      ),
    );

    if (profile.protocol == VpnProtocol.wireGuard) {
      await _wireGuardService.connect(profile.name);
    } else {
      // OpenVPN / IPsec protocol connection handler stub
      await _wireGuardService.connect(profile.name);
    }
  }

  @override
  Future<void> disconnect() => _wireGuardService.disconnect();

  @override
  Future<VpnStatus> currentStatus() => _wireGuardService.currentStatus();

  @override
  Future<VpnStatistics> statistics() => _wireGuardService.statistics();

  @override
  Future<List<String>> logs() => _wireGuardService.logs();

  @override
  Future<List<UnifiedVpnProfile>> getSavedProfiles() async {
    final keys = await _secureStorage.readAll();
    final profiles = <UnifiedVpnProfile>[];

    for (final entry in keys.entries) {
      if (entry.key.startsWith(_storagePrefix)) {
        final profileId = entry.key.replaceFirst(_storagePrefix, '');
        final raw = entry.value;
        final isWg = raw.contains('[Interface]') || raw.contains('[interface]');
        profiles.add(
          UnifiedVpnProfile(
            id: profileId,
            name: profileId,
            protocol: isWg ? VpnProtocol.wireGuard : VpnProtocol.openVpn,
            rawConfig: raw,
          ),
        );
      }
    }

    if (profiles.isEmpty) {
      final wgTunnels = await _wireGuardService.getSavedTunnels();
      for (final tunnel in wgTunnels) {
        profiles.add(
          UnifiedVpnProfile(
            id: tunnel.name,
            name: tunnel.name,
            protocol: VpnProtocol.wireGuard,
            rawConfig: tunnel.config,
          ),
        );
      }
    }

    return profiles;
  }

  @override
  Stream<VpnStatus> watchStatus() => _wireGuardService.watchStatus();
}
