import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/vpn/wireguard_config.dart';

void main() {
  group('WireGuardConfig.parse', () {
    test('parses WireGuard config with multiple peers', () {
      const config = '''
[Interface]
PrivateKey = private-key
Address = 10.7.0.2/32
DNS = 1.1.1.1, 8.8.8.8

[Peer]
PublicKey = peer-one
AllowedIPs = 10.0.0.0/24
Endpoint = vpn.example.com:51820

[Peer]
PublicKey = peer-two
AllowedIPs = 192.168.88.0/24
PersistentKeepalive = 25
''';

      final parsed = WireGuardConfig.parse(name: 'main', config: config);

      expect(parsed.name, 'main');
      expect(parsed.interfaceConfig.addresses, ['10.7.0.2/32']);
      expect(parsed.interfaceConfig.dnsServers, ['1.1.1.1', '8.8.8.8']);
      expect(parsed.peers, hasLength(2));
      expect(parsed.peers.last.persistentKeepalive, 25);
    });

    test(
      'parses config with comments, whitespace, MTU, ListenPort, and PresharedKey',
      () {
        const config = '''
# WireSpot Standalone Tunnel Config
[Interface]
PrivateKey = AAAAA/BBBBB/CCCCCC= # Primary Private Key
Address = 10.200.0.2/24, fd00::2/64
ListenPort = 51820
MTU = 1420
DNS = 1.1.1.1

[Peer]
PublicKey = XXXXX/YYYYY/ZZZZZ=
PresharedKey = psk-key-value=
Endpoint = 198.51.100.1:51820
AllowedIPs = 0.0.0.0/0, ::/0
''';

        final parsed = WireGuardConfig.parse(
          name: 'standalone_test',
          config: config,
        );

        expect(parsed.name, 'standalone_test');
        expect(parsed.interfaceConfig.privateKey, 'AAAAA/BBBBB/CCCCCC=');
        expect(parsed.interfaceConfig.addresses, [
          '10.200.0.2/24',
          'fd00::2/64',
        ]);
        expect(parsed.interfaceConfig.listenPort, 51820);
        expect(parsed.interfaceConfig.mtu, 1420);
        expect(parsed.peers.first.publicKey, 'XXXXX/YYYYY/ZZZZZ=');
        expect(parsed.peers.first.presharedKey, 'psk-key-value=');
        expect(parsed.peers.first.endpoint, '198.51.100.1:51820');
        expect(parsed.peers.first.allowedIps, ['0.0.0.0/0', '::/0']);
      },
    );

    test('throws FormatException on empty name', () {
      expect(
        () => WireGuardConfig.parse(name: '   ', config: '[Interface]'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException on missing [Interface]', () {
      const config = '''
[Peer]
PublicKey = peer-one
AllowedIPs = 10.0.0.0/24
''';
      expect(
        () => WireGuardConfig.parse(name: 'test', config: config),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('missing [Interface]'),
          ),
        ),
      );
    });

    test('parses config with lowercase section names and lowercase keys', () {
      const config = '''
[interface]
privatekey = lower-private-key
address = 10.8.0.2/24
dns = 8.8.4.4

[peer]
publickey = lower-public-key
allowedips = 0.0.0.0/0
endpoint = 203.0.113.5:51820
''';

      final parsed = WireGuardConfig.parse(
        name: 'lowercase_test',
        config: config,
      );

      expect(parsed.name, 'lowercase_test');
      expect(parsed.interfaceConfig.privateKey, 'lower-private-key');
      expect(parsed.interfaceConfig.addresses, ['10.8.0.2/24']);
      expect(parsed.interfaceConfig.dnsServers, ['8.8.4.4']);
      expect(parsed.peers.first.publicKey, 'lower-public-key');
      expect(parsed.peers.first.allowedIps, ['0.0.0.0/0']);
      expect(parsed.peers.first.endpoint, '203.0.113.5:51820');
    });

    test('throws FormatException on missing [Peer]', () {
      const config = '''
[Interface]
PrivateKey = private-key
Address = 10.0.0.1/24
''';
      expect(
        () => WireGuardConfig.parse(name: 'test', config: config),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('must include a [Peer]'),
          ),
        ),
      );
    });
  });
}
