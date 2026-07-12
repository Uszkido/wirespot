import 'hotspot_setup_plan.dart';

class HotspotSetupInput {
  const HotspotSetupInput({
    required this.serverName,
    required this.interfaceName,
    required this.serverProfileName,
    this.hotspotAddress,
    this.dnsName,
    this.addressPool,
    this.htmlDirectory,
    this.provisionNetwork = false,
    this.ipAddressWithPrefix,
    this.poolName,
    this.poolRanges,
    this.dhcpServerName,
    this.dhcpNetwork,
    this.dhcpGateway,
    this.dnsServers,
    this.enableNatMasquerade = false,
    this.natSrcAddress,
    this.natOutInterface,
    this.loginByCookie = true,
    this.loginByHttpPap = true,
    this.loginByHttps = false,
    this.useRadius = false,
    this.disabled = false,
  });

  final String serverName;
  final String interfaceName;
  final String serverProfileName;
  final String? hotspotAddress;
  final String? dnsName;
  final String? addressPool;
  final String? htmlDirectory;
  final bool provisionNetwork;
  final String? ipAddressWithPrefix;
  final String? poolName;
  final String? poolRanges;
  final String? dhcpServerName;
  final String? dhcpNetwork;
  final String? dhcpGateway;
  final String? dnsServers;
  final bool enableNatMasquerade;
  final String? natSrcAddress;
  final String? natOutInterface;
  final bool loginByCookie;
  final bool loginByHttpPap;
  final bool loginByHttps;
  final bool useRadius;
  final bool disabled;

  Map<String, String> toServerProfileAttributes() {
    return {
      'name': serverProfileName.trim(),
      if (_hasText(hotspotAddress)) 'hotspot-address': hotspotAddress!.trim(),
      if (_hasText(dnsName)) 'dns-name': dnsName!.trim(),
      if (_hasText(htmlDirectory)) 'html-directory': htmlDirectory!.trim(),
      'login-by': _loginByModes().join(','),
      'use-radius': useRadius ? 'yes' : 'no',
    };
  }

  Map<String, String> toServerAttributes() {
    final resolvedPool = _hasText(addressPool) ? addressPool : poolName;
    return {
      'name': serverName.trim(),
      'interface': interfaceName.trim(),
      'profile': serverProfileName.trim(),
      if (_hasText(resolvedPool)) 'address-pool': resolvedPool!.trim(),
      'disabled': disabled ? 'yes' : 'no',
    };
  }

  Map<String, String>? toAddressAttributes() {
    if (!provisionNetwork || !_hasText(ipAddressWithPrefix)) {
      return null;
    }
    return {
      'address': ipAddressWithPrefix!.trim(),
      'interface': interfaceName.trim(),
      'comment': _comment('address'),
    };
  }

  Map<String, String>? toPoolAttributes() {
    if (!provisionNetwork || !_hasText(poolName) || !_hasText(poolRanges)) {
      return null;
    }
    return {
      'name': poolName!.trim(),
      'ranges': poolRanges!.trim(),
    };
  }

  Map<String, String>? toDhcpServerAttributes() {
    if (!provisionNetwork || !_hasText(dhcpServerName)) {
      return null;
    }
    final resolvedPool = _hasText(poolName) ? poolName : addressPool;
    if (!_hasText(resolvedPool)) {
      return null;
    }
    return {
      'name': dhcpServerName!.trim(),
      'interface': interfaceName.trim(),
      'address-pool': resolvedPool!.trim(),
      'disabled': 'no',
    };
  }

  Map<String, String>? toDhcpNetworkAttributes() {
    if (!provisionNetwork ||
        !_hasText(dhcpNetwork) ||
        !_hasText(dhcpGateway)) {
      return null;
    }
    return {
      'address': dhcpNetwork!.trim(),
      'gateway': dhcpGateway!.trim(),
      if (_hasText(dnsServers)) 'dns-server': dnsServers!.trim(),
      'comment': _comment('network'),
    };
  }

  Map<String, String>? toNatMasqueradeAttributes() {
    if (!provisionNetwork ||
        !enableNatMasquerade ||
        !_hasText(natSrcAddress)) {
      return null;
    }
    return {
      'chain': 'srcnat',
      'action': 'masquerade',
      'src-address': natSrcAddress!.trim(),
      if (_hasText(natOutInterface)) 'out-interface': natOutInterface!.trim(),
      'comment': _comment('nat'),
    };
  }

  HotspotSetupPlan toPlan() {
    final steps = <HotspotSetupStep>[];
    final addressAttributes = toAddressAttributes();
    if (addressAttributes != null) {
      steps.add(
        HotspotSetupStep(
          title: 'Add missing interface IP address',
          command: '/ip/address/add',
          attributes: addressAttributes,
        ),
      );
    }
    final poolAttributes = toPoolAttributes();
    if (poolAttributes != null) {
      steps.add(
        HotspotSetupStep(
          title: 'Add missing IP pool',
          command: '/ip/pool/add',
          attributes: poolAttributes,
        ),
      );
    }
    final dhcpNetworkAttributes = toDhcpNetworkAttributes();
    if (dhcpNetworkAttributes != null) {
      steps.add(
        HotspotSetupStep(
          title: 'Add missing DHCP network',
          command: '/ip/dhcp-server/network/add',
          attributes: dhcpNetworkAttributes,
        ),
      );
    }
    final dhcpServerAttributes = toDhcpServerAttributes();
    if (dhcpServerAttributes != null) {
      steps.add(
        HotspotSetupStep(
          title: 'Add missing DHCP server',
          command: '/ip/dhcp-server/add',
          attributes: dhcpServerAttributes,
        ),
      );
    }
    final natAttributes = toNatMasqueradeAttributes();
    if (natAttributes != null) {
      steps.add(
        HotspotSetupStep(
          title: 'Add missing NAT masquerade rule',
          command: '/ip/firewall/nat/add',
          attributes: natAttributes,
        ),
      );
    }
    steps
      ..add(
        HotspotSetupStep(
          title: 'Create or reuse hotspot server profile',
          command: '/ip/hotspot/profile/add',
          attributes: toServerProfileAttributes(),
        ),
      )
      ..add(
        HotspotSetupStep(
          title: 'Create or update hotspot server',
          command: '/ip/hotspot/add',
          attributes: toServerAttributes(),
        ),
      );

    return HotspotSetupPlan(steps: steps);
  }

  List<String> _loginByModes() {
    final modes = <String>[];
    if (loginByCookie) {
      modes.add('cookie');
    }
    if (loginByHttpPap) {
      modes.add('http-pap');
    }
    if (loginByHttps) {
      modes.add('https');
    }
    return modes.isEmpty ? const ['http-pap'] : modes;
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String _comment(String target) {
    return 'WireSpot ${serverName.trim()} $target';
  }
}
