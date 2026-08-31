import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/vpn/openvpn_config_parser.dart';
import 'package:wirespot/core/vpn/unified_vpn_profile.dart';
import 'package:wirespot/core/vpn/vpn_protocol.dart';

void main() {
  group('OpenVpnConfigParser', () {
    test(
      'parses OpenVPN config remote host, port, proto, cipher, and inline CA',
      () {
        const config = '''
client
dev tun
proto udp
remote vpn.wirespot.net 1194
cipher AES-256-GCM
auth-user-pass

<ca>
-----BEGIN CERTIFICATE-----
MIIB/TCCAWWgAwIBAgIU
-----END CERTIFICATE-----
</ca>
''';

        final parsed = OpenVpnConfig.parse(
          name: 'office_openvpn',
          configText: config,
        );

        expect(parsed.name, 'office_openvpn');
        expect(parsed.remoteHost, 'vpn.wirespot.net');
        expect(parsed.remotePort, 1194);
        expect(parsed.transportProtocol, 'udp');
        expect(parsed.cipher, 'AES-256-GCM');
        expect(parsed.requiresUserAuth, isTrue);
        expect(parsed.hasCaCertificate, isTrue);
      },
    );

    test('throws FormatException on empty name or text', () {
      expect(
        () => OpenVpnConfig.parse(name: '  ', configText: 'client'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => OpenVpnConfig.parse(name: 'test', configText: '  '),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('UnifiedVpnProfile', () {
    test('serializes and deserializes correctly', () {
      final profile = UnifiedVpnProfile(
        id: 'prof_1',
        name: 'Enterprise IPsec',
        protocol: VpnProtocol.ipsecIkev2,
        rawConfig: 'ipsec config',
        remoteHost: '198.51.100.1',
        remotePort: 500,
        username: 'admin',
      );

      final json = profile.toJson();
      final restored = UnifiedVpnProfile.fromJson(json);

      expect(restored.id, 'prof_1');
      expect(restored.name, 'Enterprise IPsec');
      expect(restored.protocol, VpnProtocol.ipsecIkev2);
      expect(restored.remoteHost, '198.51.100.1');
      expect(restored.remotePort, 500);
      expect(restored.username, 'admin');
    });

    test('parses protocol names gracefully', () {
      expect(VpnProtocol.parse('openvpn'), VpnProtocol.openVpn);
      expect(VpnProtocol.parse('ipsec'), VpnProtocol.ipsecIkev2);
      expect(VpnProtocol.parse('sstp'), VpnProtocol.sstp);
      expect(VpnProtocol.parse('unknown'), VpnProtocol.wireGuard);
    });
  });
}
