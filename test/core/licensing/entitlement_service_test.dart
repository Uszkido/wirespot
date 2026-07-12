import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/licensing/entitlement_service.dart';
import 'package:wirespot/core/licensing/entitlement_snapshot.dart';
import 'package:wirespot/core/licensing/premium_feature.dart';

void main() {
  test('trial access allows premium features before expiry', () {
    final now = DateTime(2026, 7, 12);
    final snapshot = EntitlementSnapshot(
      isPremium: false,
      trialStartedAt: now,
      trialEndsAt: now.add(const Duration(days: 7)),
      now: now,
      deviceId: '1234567890ABCDEF',
    );

    expect(snapshot.hasAccess, isTrue);
    expect(snapshot.allows(PremiumFeature.wireGuardRemote), isTrue);
    expect(snapshot.trialDaysRemaining, 7);
  });

  test('expired trial requires license', () {
    final now = DateTime(2026, 7, 20);
    final snapshot = EntitlementSnapshot(
      isPremium: false,
      trialStartedAt: DateTime(2026, 7, 12),
      trialEndsAt: DateTime(2026, 7, 19),
      now: now,
      deviceId: '1234567890ABCDEF',
    );

    expect(snapshot.hasAccess, isFalse);
    expect(snapshot.requiresLicense, isTrue);
  });

  test('device license generator is stable', () {
    final license = EntitlementService.generateDeviceLicense(
      '1234567890abcdef',
    );

    expect(license, startsWith('WS-12345678-'));
    expect(license, hasLength(28));
  });
}
