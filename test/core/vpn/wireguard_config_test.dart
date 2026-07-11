import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/vpn/wireguard_config.dart';

void main() {
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
}
