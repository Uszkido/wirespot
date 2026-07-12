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
}
