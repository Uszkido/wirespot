import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/licensing/billing_plan.dart';
import 'package:wirespot/core/licensing/entitlement_service.dart';
import 'package:wirespot/core/licensing/entitlement_snapshot.dart';
import 'package:wirespot/core/licensing/premium_feature.dart';
import 'package:wirespot/features/settings/domain/entities/printer_config_entity.dart';
import 'package:wirespot/features/settings/domain/repositories/settings_repository.dart';

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

  test('active Play Billing entitlement grants premium access', () async {
    final repository = _FakeSettingsRepository();
    final service = EntitlementService(repository);

    await service.savePlayBillingEntitlement(
      plan: BillingPlan.proMonthly,
      endsAt: DateTime.now().add(const Duration(days: 30)),
    );

    final snapshot = await service.load();

    expect(snapshot.hasAccess, isTrue);
    expect(snapshot.isPremium, isTrue);
    expect(snapshot.source, EntitlementSource.playBilling);
    expect(snapshot.plan, BillingPlan.proMonthly);
  });

  test(
    'expired billing entitlement falls back to trial/license state',
    () async {
      final repository = _FakeSettingsRepository();
      final service = EntitlementService(repository);

      await service.savePlayBillingEntitlement(
        plan: BillingPlan.proMonthly,
        endsAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      final snapshot = await service.load();

      expect(snapshot.isPremium, isFalse);
      expect(snapshot.source, EntitlementSource.none);
      expect(snapshot.plan, BillingPlan.trial);
    },
  );
}

class _FakeSettingsRepository implements SettingsRepository {
  final _settings = <String, String>{};

  @override
  Future<void> deletePrinter(String id) async {}

  @override
  Future<List<PrinterConfigEntity>> getPrinters() async => [];

  @override
  Future<String?> readSetting(String key) async => _settings[key];

  @override
  Future<void> savePrinter(PrinterConfigEntity printer) async {}

  @override
  Future<void> writeSetting(String key, String value) async {
    _settings[key] = value;
  }
}
