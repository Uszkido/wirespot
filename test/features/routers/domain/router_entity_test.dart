import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/routers/domain/entities/router_entity.dart';

void main() {
  test('RouterEntity defaults to RouterOS plaintext API port', () {
    const router = RouterEntity(
      id: 'router-1',
      name: 'Main Router',
      host: '10.10.10.1',
      username: 'admin',
    );

    expect(router.apiPort, 8728);
    expect(router.useSsl, isFalse);
    expect(router.requireVpn, isTrue);
    expect(router.remoteAccessMode, RouterRemoteAccessMode.wireGuard);
    expect(router.vendor, RouterVendor.mikrotik);
    expect(router.supportsHotspotVouchers, isTrue);
    expect(router.requiresPrivateTunnel, isTrue);
    expect(router.isEnabled, isTrue);
  });

  test('Ruijie routers are tracked as planned non-RouterOS connectors', () {
    const router = RouterEntity(
      id: 'router-ruijie',
      name: 'Guest Reyee',
      host: '192.168.110.1',
      username: 'admin',
      vendor: RouterVendor.ruijie,
      apiPort: 443,
      useSsl: true,
    );

    expect(router.vendor.label, 'Ruijie / Reyee');
    expect(router.vendor.usesRouterOsApi, isFalse);
    expect(router.supportsHotspotVouchers, isFalse);
  });
}
