import '../../features/settings/domain/repositories/settings_repository.dart';
import 'entitlement_snapshot.dart';

class EntitlementService {
  const EntitlementService(this._settingsRepository);

  static const licenseKeySetting = 'license.key';
  static const premiumOverrideSetting = 'license.premiumOverride';

  final SettingsRepository _settingsRepository;

  Future<EntitlementSnapshot> load() async {
    final licenseKey = await _settingsRepository.readSetting(licenseKeySetting);
    final premiumOverride = await _settingsRepository.readSetting(
      premiumOverrideSetting,
    );
    return EntitlementSnapshot(
      isPremium:
          premiumOverride == 'true' || _isRecognizedDevLicense(licenseKey),
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

  bool _isRecognizedDevLicense(String? licenseKey) {
    final normalized = licenseKey?.trim().toUpperCase();
    return normalized == 'WIRESPOT-DEV-PREMIUM' ||
        normalized == 'VEXEL-WIRESPOT-PREMIUM';
  }
}
