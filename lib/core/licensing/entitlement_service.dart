import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../features/settings/domain/repositories/settings_repository.dart';
import 'entitlement_snapshot.dart';

class EntitlementService {
  const EntitlementService(this._settingsRepository);

  static const licenseKeySetting = 'license.key';
  static const premiumOverrideSetting = 'license.premiumOverride';
  static const trialStartedAtSetting = 'license.trialStartedAt';
  static const deviceIdSetting = 'license.deviceId';
  static const trialDuration = Duration(days: 7);

  final SettingsRepository _settingsRepository;

  Future<EntitlementSnapshot> load() async {
    final now = DateTime.now();
    final licenseKey = await _settingsRepository.readSetting(licenseKeySetting);
    final premiumOverride = await _settingsRepository.readSetting(
      premiumOverrideSetting,
    );
    final trialStartedAt = await _trialStartedAt(now);
    final deviceId = await _deviceId(now);
    return EntitlementSnapshot(
      isPremium:
          premiumOverride == 'true' ||
          _isRecognizedLicense(licenseKey, deviceId),
      trialStartedAt: trialStartedAt,
      trialEndsAt: trialStartedAt.add(trialDuration),
      now: now,
      deviceId: deviceId,
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

  bool _isRecognizedLicense(String? licenseKey, String deviceId) {
    final normalized = licenseKey?.trim().toUpperCase();
    if (normalized == generateDeviceLicense(deviceId)) {
      return true;
    }
    return normalized == 'WIRESPOT-DEV-PREMIUM' ||
        normalized == 'VEXEL-WIRESPOT-PREMIUM';
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
