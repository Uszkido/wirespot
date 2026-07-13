class AppText {
  const AppText(this.languageCode);

  final String languageCode;

  String get settings => _pick(en: 'Settings', fr: 'Parametres', ha: 'Saituna');

  String get security => _pick(en: 'Security', fr: 'Securite', ha: 'Tsaro');

  String get preferences =>
      _pick(en: 'Preferences', fr: 'Preferences', ha: 'Zabuka');

  String get theme => _pick(en: 'Theme', fr: 'Theme', ha: 'Launi');

  String get language => _pick(en: 'Language', fr: 'Langue', ha: 'Harshe');

  String get defaultCurrency => _pick(
    en: 'Default currency',
    fr: 'Devise par defaut',
    ha: 'Kudin da aka zaba',
  );

  String get notifications =>
      _pick(en: 'Notifications', fr: 'Notifications', ha: 'Sanarwa');

  String get premiumLicense => _pick(
    en: 'Premium license',
    fr: 'Licence premium',
    ha: 'Lasisi na premium',
  );

  String get activePlan =>
      _pick(en: 'Active plan', fr: 'Forfait actif', ha: 'Tsarin da yake aiki');

  String get trialStatus =>
      _pick(en: 'Trial status', fr: 'Etat de l essai', ha: 'Matsayin gwaji');

  String get licenseSource => _pick(
    en: 'License source',
    fr: 'Source de licence',
    ha: 'Inda lasisi ya fito',
  );

  String _pick({required String en, required String fr, required String ha}) {
    return switch (languageCode) {
      'fr' => fr,
      'ha' => ha,
      _ => en,
    };
  }
}
