import '../../../../core/branding/app_branding.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class AppSettingsService {
  const AppSettingsService(this._repository);

  final SettingsRepository _repository;

  Future<AppSettingsSnapshot> load() async {
    final theme = await _repository.readSetting(AppSettingsKeys.themeMode);
    final language = await _repository.readSetting(
      AppSettingsKeys.languageCode,
    );
    final currency = await _repository.readSetting(
      AppSettingsKeys.currencyCode,
    );
    final notifications = await _repository.readSetting(
      AppSettingsKeys.notificationsEnabled,
    );
    final businessName = await _repository.readSetting(
      AppSettingsKeys.businessName,
    );

    return AppSettingsSnapshot(
      themePreference: _themeFromString(theme),
      languageCode: _supportedLanguage(language),
      currencyCode: _supportedCurrency(currency),
      notificationsEnabled: notifications != 'false',
      businessName: businessName ?? AppBranding.companyName,
    );
  }

  Future<void> save(AppSettingsSnapshot settings) async {
    await _repository.writeSetting(
      AppSettingsKeys.themeMode,
      settings.themePreference.name,
    );
    await _repository.writeSetting(
      AppSettingsKeys.languageCode,
      settings.languageCode,
    );
    await _repository.writeSetting(
      AppSettingsKeys.currencyCode,
      settings.currencyCode,
    );
    await _repository.writeSetting(
      AppSettingsKeys.notificationsEnabled,
      settings.notificationsEnabled.toString(),
    );
    await _repository.writeSetting(
      AppSettingsKeys.businessName,
      settings.businessName,
    );
  }

  AppThemePreference _themeFromString(String? value) {
    return AppThemePreference.values.firstWhere(
      (theme) => theme.name == value,
      orElse: () => AppThemePreference.system,
    );
  }

  String _supportedLanguage(String? value) {
    final code = value ?? 'en';
    return AppSettingsOptions.languages.any((language) => language.code == code)
        ? code
        : 'en';
  }

  String _supportedCurrency(String? value) {
    final code = value ?? 'NGN';
    return AppSettingsOptions.currencies.any(
          (currency) => currency.code == code,
        )
        ? code
        : 'NGN';
  }
}
