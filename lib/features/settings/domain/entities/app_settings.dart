enum AppThemePreference { system, light, dark }

class AppSettingsKeys {
  const AppSettingsKeys._();

  static const themeMode = 'theme_mode';
  static const languageCode = 'language_code';
  static const currencyCode = 'currency_code';
  static const notificationsEnabled = 'notifications_enabled';
  static const businessName = 'business_name';
}

class SupportedLanguage {
  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  final String code;
  final String name;
  final String nativeName;
}

class SupportedCurrency {
  const SupportedCurrency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  final String code;
  final String name;
  final String symbol;

  String get label => '$code - $name ($symbol)';
}

class AppSettingsOptions {
  const AppSettingsOptions._();

  static const languages = [
    SupportedLanguage(code: 'en', name: 'English', nativeName: 'English'),
    SupportedLanguage(code: 'fr', name: 'French', nativeName: 'Francais'),
    SupportedLanguage(code: 'ha', name: 'Hausa', nativeName: 'Hausa'),
  ];

  static const currencies = [
    SupportedCurrency(code: 'NGN', name: 'Nigerian naira', symbol: 'NGN'),
    SupportedCurrency(code: 'GHS', name: 'Ghanaian cedi', symbol: 'GHc'),
    SupportedCurrency(
      code: 'XOF',
      name: 'West African CFA franc',
      symbol: 'CFA',
    ),
    SupportedCurrency(
      code: 'XAF',
      name: 'Central African CFA franc',
      symbol: 'FCFA',
    ),
    SupportedCurrency(code: 'KES', name: 'Kenyan shilling', symbol: 'KSh'),
    SupportedCurrency(code: 'UGX', name: 'Ugandan shilling', symbol: 'USh'),
    SupportedCurrency(code: 'TZS', name: 'Tanzanian shilling', symbol: 'TSh'),
    SupportedCurrency(code: 'ZAR', name: 'South African rand', symbol: 'R'),
    SupportedCurrency(code: 'EGP', name: 'Egyptian pound', symbol: 'EGP'),
    SupportedCurrency(code: 'MAD', name: 'Moroccan dirham', symbol: 'DH'),
    SupportedCurrency(code: 'USD', name: 'US dollar', symbol: r'$'),
    SupportedCurrency(code: 'EUR', name: 'Euro', symbol: 'EUR'),
    SupportedCurrency(code: 'GBP', name: 'British pound', symbol: 'GBP'),
    SupportedCurrency(code: 'CAD', name: 'Canadian dollar', symbol: 'CAD'),
    SupportedCurrency(code: 'AUD', name: 'Australian dollar', symbol: 'AUD'),
    SupportedCurrency(code: 'AED', name: 'UAE dirham', symbol: 'AED'),
  ];
}

class AppSettingsSnapshot {
  const AppSettingsSnapshot({
    required this.themePreference,
    required this.languageCode,
    required this.currencyCode,
    required this.notificationsEnabled,
    required this.businessName,
  });

  final AppThemePreference themePreference;
  final String languageCode;
  final String currencyCode;
  final bool notificationsEnabled;
  final String businessName;

  AppSettingsSnapshot copyWith({
    AppThemePreference? themePreference,
    String? languageCode,
    String? currencyCode,
    bool? notificationsEnabled,
    String? businessName,
  }) {
    return AppSettingsSnapshot(
      themePreference: themePreference ?? this.themePreference,
      languageCode: languageCode ?? this.languageCode,
      currencyCode: currencyCode ?? this.currencyCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      businessName: businessName ?? this.businessName,
    );
  }
}
