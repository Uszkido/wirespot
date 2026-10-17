import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/hotspot/domain/entities/radius_subscriber.dart';

void main() {
  test('validates a subscriber and maps FreeRADIUS attributes', () {
    const subscriber = RadiusSubscriber(
      username: 'customer-001',
      password: 'secret',
      planName: '5 Mbps',
      rateLimit: '5M/5M',
      sessionTimeoutSeconds: 3600,
    );

    expect(subscriber.validationErrors, isEmpty);
    expect(subscriber.toAuthorizeEntry(), contains('customer-001'));
    expect(
      subscriber.toAuthorizeEntry(),
      contains('Mikrotik-Rate-Limit := "5M/5M"'),
    );
    expect(subscriber.toAuthorizeEntry(), contains('Session-Timeout := 3600'));
  });

  test('disabled subscriber is rejected and secrets are escaped', () {
    const subscriber = RadiusSubscriber(
      username: 'customer-002',
      password: 'pa"ss',
      planName: 'Trial',
      rateLimit: '1M/1M',
      disabled: true,
    );

    final entry = subscriber.toAuthorizeEntry();
    expect(entry, contains('Cleartext-Password := "pa\\"ss"'));
    expect(entry, contains('Auth-Type := Reject'));
  });
}
