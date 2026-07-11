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
    expect(router.isEnabled, isTrue);
  });
}
