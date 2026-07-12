enum AppThemePreference { system, light, dark }

class AppSettingsKeys {
  const AppSettingsKeys._();

  static const themeMode = 'theme_mode';
  static const languageCode = 'language_code';
  static const notificationsEnabled = 'notifications_enabled';
  static const businessName = 'business_name';
}

class AppSettingsSnapshot {
  const AppSettingsSnapshot({
    required this.themePreference,
    required this.languageCode,
    required this.notificationsEnabled,
    required this.businessName,
  });

  final AppThemePreference themePreference;
  final String languageCode;
  final bool notificationsEnabled;
  final String businessName;

  AppSettingsSnapshot copyWith({
    AppThemePreference? themePreference,
    String? languageCode,
    bool? notificationsEnabled,
    String? businessName,
  }) {
    return AppSettingsSnapshot(
      themePreference: themePreference ?? this.themePreference,
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      businessName: businessName ?? this.businessName,
    );
  }
}
