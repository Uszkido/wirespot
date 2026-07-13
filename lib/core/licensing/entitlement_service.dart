import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../features/settings/domain/repositories/settings_repository.dart';
import 'billing_plan.dart';
import 'entitlement_snapshot.dart';

class EntitlementService {
  const EntitlementService(this._settingsRepository);

  static const licenseKeySetting = 'license.key';
  static const premiumOverrideSetting = 'license.premiumOverride';
  static const trialStartedAtSetting = 'license.trialStartedAt';
  static const deviceIdSetting = 'license.deviceId';
  static const billingPlanSetting = 'license.billing.plan';
  static const billingSourceSetting = 'license.billing.source';
  static const billingStatusSetting = 'license.billing.status';
  static const billingEndsAtSetting = 'license.billing.endsAt';
  static const trialDuration = Duration(days: 7);

  final SettingsRepository _settingsRepository;

  Future<EntitlementSnapshot> load() async {
    final now = DateTime.now();
    final licenseKey = await _settingsRepository.readSetting(licenseKeySetting);
    final premiumOverride = await _settingsRepository.readSetting(
      premiumOverrideSetting,
    );
    final billingEntitlement = await _billingEntitlement(now);
    final trialStartedAt = await _trialStartedAt(now);
    final deviceId = await _deviceId(now);
    final licenseSource = _licenseSource(
      licenseKey: licenseKey,
      deviceId: deviceId,
      premiumOverride: premiumOverride == 'true',
    );
    final isLicensePremium = licenseSource != EntitlementSource.none;
    return EntitlementSnapshot(
      isPremium: isLicensePremium || billingEntitlement.isActive,
      trialStartedAt: trialStartedAt,
      trialEndsAt: trialStartedAt.add(trialDuration),
      now: now,
      deviceId: deviceId,
      source: billingEntitlement.isActive
          ? billingEntitlement.source
          : licenseSource,
      plan: billingEntitlement.isActive
          ? billingEntitlement.plan
          : _planForLicenseSource(licenseSource),
      entitlementEndsAt: billingEntitlement.endsAt,
      licenseKey: licenseKey,
    );
  }

  Future<void> saveDevLicense(String licenseKey) async {
    await _settingsRepository.writeSetting(
      licenseKeySetting,
      licenseKey.trim(),
    );
  }

  Future<void> setPremiumOverride(bool enabled) async {
    await _settingsRepository.writeSetting(
      premiumOverrideSetting,
      enabled ? 'true' : 'false',
    );
  }

  Future<void> savePlayBillingEntitlement({
    required BillingPlan plan,
    required DateTime endsAt,
  }) async {
    await _settingsRepository.writeSetting(billingPlanSetting, plan.id);
    await _settingsRepository.writeSetting(
      billingSourceSetting,
      EntitlementSource.playBilling.name,
    );
    await _settingsRepository.writeSetting(billingStatusSetting, 'active');
    await _settingsRepository.writeSetting(
      billingEndsAtSetting,
      endsAt.toIso8601String(),
    );
  }

  Future<void> saveServerEntitlement({
    required BillingPlan plan,
    required DateTime endsAt,
  }) async {
    await _settingsRepository.writeSetting(billingPlanSetting, plan.id);
    await _settingsRepository.writeSetting(
      billingSourceSetting,
      EntitlementSource.serverLicense.name,
    );
    await _settingsRepository.writeSetting(billingStatusSetting, 'active');
    await _settingsRepository.writeSetting(
      billingEndsAtSetting,
      endsAt.toIso8601String(),
    );
  }

  Future<void> clearBillingEntitlement() async {
    await _settingsRepository.writeSetting(billingStatusSetting, 'inactive');
  }

  bool _isRecognizedLicense(String? licenseKey, String deviceId) {
    final normalized = licenseKey?.trim().toUpperCase();
    if (normalized == generateDeviceLicense(deviceId)) {
      return true;
    }
    return normalized == 'WIRESPOT-DEV-PREMIUM' ||
        normalized == 'VEXEL-WIRESPOT-PREMIUM';
  }

  EntitlementSource _licenseSource({
    required String? licenseKey,
    required String deviceId,
    required bool premiumOverride,
  }) {
    if (premiumOverride) {
      return EntitlementSource.development;
    }
    final normalized = licenseKey?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) {
      return EntitlementSource.none;
    }
    if (normalized == generateDeviceLicense(deviceId)) {
      return EntitlementSource.deviceLicense;
    }
    if (_isRecognizedLicense(normalized, deviceId)) {
      return EntitlementSource.development;
    }
    return EntitlementSource.none;
  }

  BillingPlan _planForLicenseSource(EntitlementSource source) {
    return switch (source) {
      EntitlementSource.deviceLicense => BillingPlan.lifetimeDevice,
      EntitlementSource.playBilling => BillingPlan.proMonthly,
      EntitlementSource.serverLicense => BillingPlan.proMonthly,
      EntitlementSource.development => BillingPlan.proMonthly,
      EntitlementSource.trial => BillingPlan.trial,
      EntitlementSource.none => BillingPlan.trial,
    };
  }

  Future<_BillingEntitlement> _billingEntitlement(DateTime now) async {
    final status = await _settingsRepository.readSetting(billingStatusSetting);
    if (status != 'active') {
      return _BillingEntitlement.inactive();
    }
    final source = _sourceFromName(
      await _settingsRepository.readSetting(billingSourceSetting),
    );
    final plan = BillingPlan.fromId(
      await _settingsRepository.readSetting(billingPlanSetting),
    );
    final endsAtText = await _settingsRepository.readSetting(
      billingEndsAtSetting,
    );
    final endsAt = endsAtText == null ? null : DateTime.tryParse(endsAtText);
    if (endsAt == null || !endsAt.isAfter(now)) {
      return _BillingEntitlement.inactive();
    }
    return _BillingEntitlement(
      isActive: true,
      source: source,
      plan: plan,
      endsAt: endsAt,
    );
  }

  EntitlementSource _sourceFromName(String? source) {
    return EntitlementSource.values.firstWhere(
      (value) => value.name == source,
      orElse: () => EntitlementSource.none,
    );
  }

  static String generateDeviceLicense(String deviceId) {
    final normalizedDevice = deviceId.trim().toUpperCase();
    if (normalizedDevice.length < 8) {
      throw ArgumentError.value(deviceId, 'deviceId', 'Use at least 8 chars');
    }
    final digest = sha256
        .convert(utf8.encode('wirespot-v1:$normalizedDevice'))
        .toString()
        .toUpperCase();
    return 'WS-${normalizedDevice.substring(0, 8)}-${digest.substring(0, 16)}';
  }

  Future<DateTime> _trialStartedAt(DateTime now) async {
    final stored = await _settingsRepository.readSetting(trialStartedAtSetting);
    final parsed = stored == null ? null : DateTime.tryParse(stored);
    if (parsed != null) {
      return parsed;
    }
    await _settingsRepository.writeSetting(
      trialStartedAtSetting,
      now.toIso8601String(),
    );
    return now;
  }

  Future<String> _deviceId(DateTime now) async {
    final stored = await _settingsRepository.readSetting(deviceIdSetting);
    if (stored != null && stored.trim().length >= 8) {
      return stored.trim().toUpperCase();
    }
    final seed = '${now.microsecondsSinceEpoch}${now.millisecond}';
    final id = sha256
        .convert(utf8.encode(seed))
        .toString()
        .substring(0, 16)
        .toUpperCase();
    await _settingsRepository.writeSetting(deviceIdSetting, id);
    return id;
  }
}

class _BillingEntitlement {
  const _BillingEntitlement({
    required this.isActive,
    required this.source,
    required this.plan,
    required this.endsAt,
  });

  factory _BillingEntitlement.inactive() {
    return const _BillingEntitlement(
      isActive: false,
      source: EntitlementSource.none,
      plan: BillingPlan.trial,
      endsAt: null,
    );
  }

  final bool isActive;
  final EntitlementSource source;
  final BillingPlan plan;
  final DateTime? endsAt;
}
