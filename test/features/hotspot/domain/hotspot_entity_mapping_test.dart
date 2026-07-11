import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_active_session_entity.dart';
import 'package:wirespot/features/hotspot/domain/entities/hotspot_user_entity.dart';

void main() {
  test('HotspotUserEntity maps RouterOS records', () {
    final user = HotspotUserEntity.fromRouterOs({
      '.id': '*1',
      'name': 'guest001',
      'profile': 'default',
      'disabled': 'false',
      'bytes-in': '100',
      'bytes-out': '200',
    });

    expect(user.id, '*1');
    expect(user.name, 'guest001');
    expect(user.profile, 'default');
    expect(user.disabled, isFalse);
    expect(user.bytesIn, 100);
    expect(user.bytesOut, 200);
  });

  test('HotspotActiveSessionEntity maps RouterOS records', () {
    final session = HotspotActiveSessionEntity.fromRouterOs({
      '.id': '*2',
      'user': 'guest001',
      'address': '10.5.50.10',
      'mac-address': 'AA:BB:CC:DD:EE:FF',
      'bytes-in': '300',
      'bytes-out': '400',
    });

    expect(session.id, '*2');
    expect(session.user, 'guest001');
    expect(session.address, '10.5.50.10');
    expect(session.bytesIn, 300);
    expect(session.bytesOut, 400);
  });
}
