import '../../features/settings/domain/repositories/settings_repository.dart';
import 'billing_plan.dart';
import 'entitlement_snapshot.dart';

abstract interface class ServerEntitlementReader {
  Future<Map<String, dynamic>?> fetchEntitlement();
}

class EntitlementService {
  const EntitlementService(
    this._settingsRepository, {
    ServerEntitlementReader? serverEntitlementReader,
  }) : _serverEntitlementReader = serverEntitlementReader;

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
  final ServerEntitlementReader? _serverEntitlementReader;

  Future<EntitlementSnapshot> load() async {
    final now = DateTime.now();
    final licenseKey = await _settingsRepository.readSetting(licenseKeySetting);
    final premiumOverride = await _settingsRepository.readSetting(
      premiumOverrideSetting,
    );
    final billingEntitlement = await _billingEntitlement(now);
    final trialStartedAt = await _trialStartedAt(now);
    final deviceId = await _deviceId(now);
    final localLicense = _localLicense(licenseKey, deviceId, now);
    final serverEntitlement = await _loadServerEntitlement(deviceId, now);
    final licenseSource = _licenseSource(
      licenseKey: licenseKey,
      deviceId: deviceId,
      premiumOverride: premiumOverride == 'true',
    );
    final isLicensePremium = licenseSource != EntitlementSource.none;
    final premium =
        serverEntitlement != null ||
        isLicensePremium ||
        billingEntitlement.isActive;
    return EntitlementSnapshot(
      isPremium: premium,
      trialStartedAt: trialStartedAt,
      trialEndsAt: trialStartedAt.add(trialDuration),
      now: now,
      deviceId: deviceId,
      source: billingEntitlement.isActive
          ? billingEntitlement.source
          : serverEntitlement != null
          ? EntitlementSource.serverLicense
          : licenseSource,
      plan: billingEntitlement.isActive
          ? billingEntitlement.plan
          : serverEntitlement?.plan ??
                localLicense?.plan ??
                _planForLicenseSource(licenseSource),
      entitlementEndsAt: billingEntitlement.isActive
          ? billingEntitlement.endsAt
          : serverEntitlement?.endsAt ?? localLicense?.endsAt,
      licenseKey: licenseKey,
    );
  }

  Future<_LocalLicense?> _loadServerEntitlement(
    String deviceId,
    DateTime now,
  ) async {
    final reader = _serverEntitlementReader;
    if (reader == null) return null;
    try {
      final payload = await reader.fetchEntitlement();
      if (payload == null ||
          payload['verified'] != true ||
          payload['revoked'] == true) {
        return null;
      }
      final licensedDevice = (payload['deviceId'] as String?)
          ?.trim()
          .toUpperCase();
      final endsAt = DateTime.tryParse(payload['endsAt'] as String? ?? '');
      final plan = BillingPlan.fromId(payload['plan'] as String?);
      if (licensedDevice != deviceId.toUpperCase() ||
          endsAt == null ||
          !endsAt.isAfter(now) ||
          plan == BillingPlan.trial ||
          plan == BillingPlan.lifetimeDevice) {
        return null;
      }
      return _LocalLicense(plan: plan, endsAt: endsAt);
    } on Object {
      return null;
    }
  }

  Future<void> saveDevLicense(String licenseKey) async {
    await _settingsRepository.writeSetting(
      licenseKeySetting,
      licenseKey.trim(),
    );
  }

  /// Removes the locally activated license from this device.
  ///
  /// This does not revoke a server or Play Store purchase; it only deactivates
  /// the current device so the key can be issued or applied elsewhere.
  Future<void> deactivateDevice() async {
    await _settingsRepository.writeSetting(licenseKeySetting, '');
    await clearBillingEntitlement();
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
    if (normalized == null || normalized.isEmpty) {
      return false;
    }
    if (normalized == generateDeviceLicense(deviceId) ||
        _isLegacyDeviceLicense(normalized, deviceId) ||
        _localLicense(normalized, deviceId, DateTime.now()) != null) {
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
    if (normalized == generateDeviceLicense(deviceId) ||
        _isLegacyDeviceLicense(normalized, deviceId) ||
        _localLicense(normalized, deviceId, DateTime.now()) != null) {
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
    final digest = _licenseDigest(normalizedDevice);
    return 'VEXEL-${normalizedDevice.substring(0, 4)}-'
        '${digest.substring(0, 4)}';
  }

  static String generateLegacyDeviceLicense(String deviceId) {
    final normalizedDevice = deviceId.trim().toUpperCase();
    if (normalizedDevice.length < 8) {
      throw ArgumentError.value(deviceId, 'deviceId', 'Use at least 8 chars');
    }
    final digest = _licenseDigest(normalizedDevice);
    return 'WS-${normalizedDevice.substring(0, 8)}-${digest.substring(0, 16)}';
  }

  /// Generates a time-limited offline key for direct/enterprise installs.
  /// The expiry is checked locally, so server-issued entitlements remain the
  /// stronger option when revocation or clock tamper resistance is required.
  static String generateTimedDeviceLicense({
    required String deviceId,
    required BillingPlan plan,
    required DateTime endsAt,
  }) {
    if (plan != BillingPlan.smallMonthly &&
        plan != BillingPlan.proMonthly &&
        plan != BillingPlan.proYearly) {
      throw ArgumentError.value(plan, 'plan', 'Use a monthly or yearly plan');
    }
    final normalizedDevice = deviceId.trim().toUpperCase();
    if (normalizedDevice.length < 8) {
      throw ArgumentError.value(deviceId, 'deviceId', 'Use at least 8 chars');
    }
    final date = _licenseDate(endsAt);
    final planCode = plan == BillingPlan.proYearly ? 'Y' : 'M';
    final digest = _licenseDigest('$normalizedDevice:$planCode:$date');
    return 'VEXEL-$planCode-${normalizedDevice.substring(0, 4)}-$date-${digest.substring(0, 8)}';
  }

  static bool _isLegacyDeviceLicense(String licenseKey, String deviceId) {
    final normalizedDevice = deviceId.trim().toUpperCase();
    if (normalizedDevice.length < 8) {
      return false;
    }
    return licenseKey.startsWith('WS-${normalizedDevice.substring(0, 8)}-') &&
        licenseKey.length == 28;
  }

  _LocalLicense? _localLicense(
    String? licenseKey,
    String deviceId,
    DateTime now,
  ) {
    final normalized = licenseKey?.trim().toUpperCase();
    if (normalized == null) return null;
    final match = RegExp(
      r'^VEXEL-([MY])-([A-Z0-9]{4})-(\d{8})-([A-F0-9]{8})$',
    ).firstMatch(normalized);
    if (match == null || !deviceId.toUpperCase().startsWith(match.group(2)!)) {
      return null;
    }
    final dateText = match.group(3)!;
    final endsAt = DateTime.tryParse(
      '${dateText.substring(0, 4)}-${dateText.substring(4, 6)}-${dateText.substring(6, 8)}T23:59:59Z',
    );
    if (endsAt == null || !endsAt.isAfter(now.toUtc())) return null;
    final plan = match.group(1) == 'Y'
        ? BillingPlan.proYearly
        : BillingPlan.proMonthly;
    final expected = _licenseDigest(
      '${deviceId.toUpperCase()}:${match.group(1)}:$dateText',
    ).substring(0, 8);
    if (expected != match.group(4)) return null;
    return _LocalLicense(plan: plan, endsAt: endsAt);
  }

  static String _licenseDate(DateTime value) {
    final utc = value.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}'
        '${utc.month.toString().padLeft(2, '0')}'
        '${utc.day.toString().padLeft(2, '0')}';
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
    final seed = now.microsecondsSinceEpoch.toRadixString(16).toUpperCase();
    final id = seed.padLeft(16, '0').substring(0, 16);
    await _settingsRepository.writeSetting(deviceIdSetting, id);
    return id;
  }

  static String _licenseDigest(String deviceId) {
    var hash = 0x811C9DC5;
    final input = 'wirespot-v2:$deviceId';
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    final first = hash.toRadixString(16).padLeft(8, '0');
    final second = ((hash ^ 0xA5A5A5A5) & 0xFFFFFFFF)
        .toRadixString(16)
        .padLeft(8, '0');
    return '$first$second'.toUpperCase();
  }
}

class _LocalLicense {
  const _LocalLicense({required this.plan, required this.endsAt});

  final BillingPlan plan;
  final DateTime endsAt;
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
