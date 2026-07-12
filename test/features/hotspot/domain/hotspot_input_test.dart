import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_ip_binding_input.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_profile_input.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_setup_input.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_user_input.dart';

void main() {
  test('HotspotUserInput maps to RouterOS attributes', () {
    const input = HotspotUserInput(
      username: 'guest001',
      password: 'pass001',
      profile: '1-hour',
      limitUptime: '1h',
      limitBytesTotal: 1024,
    );

    expect(input.toRouterOsAttributes(), {
      'name': 'guest001',
      'password': 'pass001',
      'profile': '1-hour',
      'limit-uptime': '1h',
      'limit-bytes-total': '1024',
    });
  });

  test('HotspotProfileInput maps rate limits and session settings', () {
    const input = HotspotProfileInput(
      name: 'basic',
      rateLimit: '2M/2M',
      sessionTimeout: '1h',
      sharedUsers: 1,
    );

    expect(input.toRouterOsAttributes(), {
      'name': 'basic',
      'rate-limit': '2M/2M',
      'session-timeout': '1h',
      'shared-users': '1',
    });
  });

  test('HotspotIpBindingInput maps bypass rules', () {
    const input = HotspotIpBindingInput(
      macAddress: 'AA:BB:CC:DD:EE:FF',
      type: 'bypassed',
      comment: 'Admin device',
    );

    expect(input.toRouterOsAttributes(), {
      'mac-address': 'AA:BB:CC:DD:EE:FF',
      'type': 'bypassed',
      'comment': 'Admin device',
    });
  });

  test('HotspotSetupInput maps server profile and server attributes', () {
    const input = HotspotSetupInput(
      serverName: 'hotspot1',
      interfaceName: 'bridge',
      serverProfileName: 'hsprof1',
      hotspotAddress: '10.5.50.1',
      dnsName: 'hotspot.local',
      addressPool: 'hs-pool',
      loginByCookie: true,
      loginByHttpPap: true,
      loginByHttps: false,
      useRadius: false,
    );

    expect(input.toServerProfileAttributes(), {
      'name': 'hsprof1',
      'hotspot-address': '10.5.50.1',
      'dns-name': 'hotspot.local',
      'login-by': 'cookie,http-pap',
      'use-radius': 'no',
    });
    expect(input.toServerAttributes(), {
      'name': 'hotspot1',
      'interface': 'bridge',
      'profile': 'hsprof1',
      'address-pool': 'hs-pool',
      'disabled': 'no',
    });
  });

  test('HotspotSetupInput maps optional network provisioning attributes', () {
    const input = HotspotSetupInput(
      serverName: 'hotspot1',
      interfaceName: 'bridge',
      serverProfileName: 'hsprof1',
      provisionNetwork: true,
      ipAddressWithPrefix: '10.5.50.1/24',
      poolName: 'hs-pool',
      poolRanges: '10.5.50.10-10.5.50.254',
      dhcpServerName: 'hs-dhcp',
      dhcpNetwork: '10.5.50.0/24',
      dhcpGateway: '10.5.50.1',
      dnsServers: '10.5.50.1,8.8.8.8',
      enableNatMasquerade: true,
      natSrcAddress: '10.5.50.0/24',
      natOutInterface: 'ether1',
    );

    expect(input.toAddressAttributes(), {
      'address': '10.5.50.1/24',
      'interface': 'bridge',
      'comment': 'WireSpot hotspot1 address',
    });
    expect(input.toPoolAttributes(), {
      'name': 'hs-pool',
      'ranges': '10.5.50.10-10.5.50.254',
    });
    expect(input.toDhcpServerAttributes(), {
      'name': 'hs-dhcp',
      'interface': 'bridge',
      'address-pool': 'hs-pool',
      'disabled': 'no',
    });
    expect(input.toDhcpNetworkAttributes(), {
      'address': '10.5.50.0/24',
      'gateway': '10.5.50.1',
      'dns-server': '10.5.50.1,8.8.8.8',
      'comment': 'WireSpot hotspot1 network',
    });
    expect(input.toNatMasqueradeAttributes(), {
      'chain': 'srcnat',
      'action': 'masquerade',
      'src-address': '10.5.50.0/24',
      'out-interface': 'ether1',
      'comment': 'WireSpot hotspot1 nat',
    });
  });

  test('HotspotSetupInput creates ordered setup plan', () {
    const input = HotspotSetupInput(
      serverName: 'hotspot1',
      interfaceName: 'bridge',
      serverProfileName: 'hsprof1',
      provisionNetwork: true,
      ipAddressWithPrefix: '10.5.50.1/24',
      poolName: 'hs-pool',
      poolRanges: '10.5.50.10-10.5.50.254',
      dhcpServerName: 'hs-dhcp',
      dhcpNetwork: '10.5.50.0/24',
      dhcpGateway: '10.5.50.1',
      enableNatMasquerade: true,
      natSrcAddress: '10.5.50.0/24',
    );

    final plan = input.toPlan();

    expect(plan.steps.map((step) => step.command), [
      '/ip/address/add',
      '/ip/pool/add',
      '/ip/dhcp-server/network/add',
      '/ip/dhcp-server/add',
      '/ip/firewall/nat/add',
      '/ip/hotspot/profile/add',
      '/ip/hotspot/add',
    ]);
    expect(plan.toLines().first, 'Add missing interface IP address');
  });
}
