import 'hotspot_setup_plan.dart';
import 'radius_server_settings.dart';

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
    this.radiusSettings,
    this.configurePppoe = false,
    this.pppoeInterface = 'ether1',
    this.pppoeUsername,
    this.pppoePassword,
    this.pppoeClientName = 'pppoe-wan',
    this.configurePppoeServer = false,
    this.pppoeServerInterface,
    this.pppoeServiceName = 'WireSpot-PPPoE',
    this.pppoeProfileName = 'WireSpot-PPPoE-Profile',
    this.pppoeLocalAddress,
    this.pppoeRemotePool,
    this.pppoeRemotePoolRanges = '10.50.0.10-10.50.0.254',
    this.pppoeRadiusSettings,
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
  final RadiusServerSettings? radiusSettings;
  final bool configurePppoe;
  final String? pppoeInterface;
  final String? pppoeUsername;
  final String? pppoePassword;
  final String pppoeClientName;
  final bool configurePppoeServer;
  final String? pppoeServerInterface;
  final String pppoeServiceName;
  final String pppoeProfileName;
  final String? pppoeLocalAddress;
  final String? pppoeRemotePool;
  final String pppoeRemotePoolRanges;
  final RadiusServerSettings? pppoeRadiusSettings;
  final bool disabled;

  List<String> get validationErrors {
    final errors = <String>[];
    if (!_hasText(serverName)) {
      errors.add('Enter a hotspot server name.');
    }
    if (!_hasText(interfaceName)) {
      errors.add('Choose the interface that will run the hotspot.');
    }
    if (!_hasText(serverProfileName)) {
      errors.add('Enter a hotspot server profile name.');
    }
    if (!_hasText(addressPool) && !(_hasText(poolName) && provisionNetwork)) {
      errors.add('Enter an address pool or enable network provisioning.');
    }
    if (provisionNetwork) {
      if (!_hasText(ipAddressWithPrefix)) {
        errors.add('Enter the interface IP address.');
      }
      if (!_hasText(poolName) || !_hasText(poolRanges)) {
        errors.add('Enter the IP pool name and range.');
      }
      if (!_hasText(dhcpServerName)) {
        errors.add('Enter the DHCP server name.');
      }
      if (!_hasText(dhcpNetwork) || !_hasText(dhcpGateway)) {
        errors.add('Enter the DHCP network and gateway.');
      }
      if (enableNatMasquerade && !_hasText(natSrcAddress)) {
        errors.add('Enter the NAT source network.');
      }
    }
    if (useRadius) {
      if (radiusSettings == null) {
        errors.add('Add the RADIUS server settings.');
      } else {
        errors.addAll(radiusSettings!.validationErrors);
      }
    }
    if (configurePppoe) {
      if (!_hasText(pppoeInterface)) {
        errors.add('Enter the PPPoE WAN interface.');
      }
      if (!_hasText(pppoeUsername)) {
        errors.add('Enter the ISP PPPoE username.');
      }
      if (!_hasText(pppoePassword)) {
        errors.add('Enter the ISP PPPoE password.');
      }
      if (!_hasText(pppoeClientName)) {
        errors.add('Enter the PPPoE client name.');
      }
    }
    if (configurePppoeServer) {
      if (!_hasText(pppoeServerInterface)) {
        errors.add('Enter the PPPoE server interface.');
      }
      if (!_hasText(pppoeServiceName)) {
        errors.add('Enter the PPPoE service name.');
      }
      if (!_hasText(pppoeProfileName)) {
        errors.add('Enter the PPPoE profile name.');
      }
      if (!_hasText(pppoeLocalAddress)) {
        errors.add('Enter the PPPoE local address.');
      }
      if (!_hasText(pppoeRemotePool)) {
        errors.add('Enter the PPPoE remote address pool.');
      }
      if (!_hasText(pppoeRemotePoolRanges)) {
        errors.add('Enter the PPPoE pool ranges.');
      }
      if (pppoeRadiusSettings == null) {
        errors.add('Add RADIUS settings for PPPoE authentication.');
      } else {
        errors.addAll(pppoeRadiusSettings!.validationErrors);
      }
    }
    return errors;
  }

  Map<String, String>? toRadiusAttributes() {
    if (!useRadius || radiusSettings == null) return null;
    return radiusSettings!.toRouterOsAttributes();
  }

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

  Map<String, String>? toPppoeAttributes() {
    if (!configurePppoe) return null;
    return {
      'name': pppoeClientName.trim(),
      'interface': pppoeInterface!.trim(),
      'user': pppoeUsername!.trim(),
      'password': pppoePassword!,
      'add-default-route': 'yes',
      'use-peer-dns': 'yes',
      'disabled': 'no',
      'comment': _comment('pppoe'),
    };
  }

  Map<String, String>? toPppoeNatAttributes() {
    if (!configurePppoe) return null;
    return {
      'chain': 'srcnat',
      'out-interface': pppoeClientName.trim(),
      'action': 'masquerade',
      'comment': _comment('pppoe-nat'),
    };
  }

  Map<String, String>? toPppoeProfileAttributes() {
    if (!configurePppoeServer) return null;
    return {
      'name': pppoeProfileName.trim(),
      'local-address': pppoeLocalAddress!.trim(),
      'remote-address': pppoeRemotePool!.trim(),
      'use-radius': 'yes',
      'comment': _comment('pppoe-profile'),
    };
  }

  Map<String, String>? toPppoePoolAttributes() {
    if (!configurePppoeServer) return null;
    return {
      'name': pppoeRemotePool!.trim(),
      'ranges': pppoeRemotePoolRanges.trim(),
      'comment': _comment('pppoe-pool'),
    };
  }

  Map<String, String>? toPppoeServerAttributes() {
    if (!configurePppoeServer) return null;
    return {
      'interface': pppoeServerInterface!.trim(),
      'service-name': pppoeServiceName.trim(),
      'default-profile': pppoeProfileName.trim(),
      'authentication': 'pap,chap,mschap1,mschap2',
      'one-session-per-host': 'yes',
      'disabled': 'no',
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
    return {'name': poolName!.trim(), 'ranges': poolRanges!.trim()};
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
    if (!provisionNetwork || !_hasText(dhcpNetwork) || !_hasText(dhcpGateway)) {
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
    if (!provisionNetwork || !enableNatMasquerade || !_hasText(natSrcAddress)) {
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
    final pppoeAttributes = toPppoeAttributes();
    if (pppoeAttributes != null) {
      steps.add(
        HotspotSetupStep(
          title: 'Create or update PPPoE WAN client',
          command:
              '/interface/pppoe-client/add (or /interface/pppoe-client/set)',
          attributes: {
            for (final entry in pppoeAttributes.entries)
              entry.key: entry.key == 'password' ? '••••••••' : entry.value,
          },
        ),
      );
      steps.add(
        HotspotSetupStep(
          title: 'Add PPPoE Internet NAT masquerade',
          command: '/ip/firewall/nat/add',
          attributes: toPppoeNatAttributes()!,
        ),
      );
    }
    final pppoeProfile = toPppoeProfileAttributes();
    if (pppoeProfile != null) {
      steps.add(
        HotspotSetupStep(
          title: 'Create or update PPPoE subscriber address pool',
          command: '/ip/pool/add (or /ip/pool/set)',
          attributes: toPppoePoolAttributes()!,
        ),
      );
      steps.add(
        HotspotSetupStep(
          title: 'Create or update PPPoE subscriber profile',
          command: '/ppp/profile/add (or /ppp/profile/set)',
          attributes: pppoeProfile,
        ),
      );
      steps.add(
        HotspotSetupStep(
          title: 'Create PPPoE server',
          command: '/interface/pppoe-server/server/add',
          attributes: toPppoeServerAttributes()!,
        ),
      );
      final radius = pppoeRadiusSettings!.toRouterOsAttributes();
      steps.add(
        HotspotSetupStep(
          title: 'Enable FreeRADIUS for PPPoE authentication and accounting',
          command: '/radius/add (service=ppp) and /ppp/aaa/set',
          attributes: {
            for (final entry in radius.entries)
              entry.key: entry.key == 'secret' ? '••••••••' : entry.value,
            'use-radius': 'yes',
            'accounting': 'yes',
          },
        ),
      );
    }
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

    final radiusAttributes = toRadiusAttributes();
    if (radiusAttributes != null) {
      steps.add(
        HotspotSetupStep(
          title: 'Create or update external RADIUS server',
          command: '/radius/add (or /radius/set)',
          // Never expose the shared secret in the review dialog, logs, or
          // generated setup plan. The live RouterOS request still receives it.
          attributes: {
            for (final entry in radiusAttributes.entries)
              entry.key: entry.key == 'secret' ? '••••••••' : entry.value,
          },
        ),
      );
    }

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
