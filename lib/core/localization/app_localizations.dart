enum AppLanguage {
  english(code: 'en', label: 'English'),
  french(code: 'fr', label: 'Français'),
  swahili(code: 'sw', label: 'Kiswahili'),
  hausa(code: 'ha', label: 'Hausa'),
  yoruba(code: 'yo', label: 'Yorùbá'),
  igbo(code: 'ig', label: 'Asụsụ Igbo'),
  pidgin(code: 'pcm', label: 'Naija Pidgin'),
  arabic(code: 'ar', label: 'العربية'),
  spanish(code: 'es', label: 'Español');

  const AppLanguage({required this.code, required this.label});
  final String code;
  final String label;

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code.toLowerCase(),
      orElse: () => AppLanguage.english,
    );
  }
}

class AppLocalizations {
  const AppLocalizations(this.language);

  final AppLanguage language;

  static final Map<AppLanguage, Map<String, String>> _localizedValues = {
    AppLanguage.english: {
      'dashboard': 'Dashboard',
      'router_fleet': 'Router Fleet',
      'hotspot_users': 'Hotspot Users',
      'vouchers': 'Vouchers',
      'reports': 'Reports',
      'settings': 'Settings',
      'generate_vouchers': 'Generate Vouchers',
      'connect_router': 'Connect Router',
      'active_sessions': 'Active Sessions',
      'total_revenue': 'Total Revenue',
      'cloud_sync': 'Cloud Sync',
    },
    AppLanguage.hausa: {
      'dashboard': 'Shafin Farko',
      'router_fleet': 'Kayan Router',
      'hotspot_users': 'Masu Amfani da Hotspot',
      'vouchers': 'Katin Samun Intanet',
      'reports': 'Rahotanni',
      'settings': 'Tsare-tsare',
      'generate_vouchers': 'Hada Katukan Intanet',
      'connect_router': "Hada Na'ura",
      'active_sessions': 'Mutane Masu Amfani Yanzu',
      'total_revenue': 'Cikakken Kudin Shiga',
      'cloud_sync': 'Tura Bayanai zuwa Cloud',
    },
    AppLanguage.yoruba: {
      'dashboard': 'Oju-ewe Agbara',
      'router_fleet': 'Awon Ero Router',
      'hotspot_users': 'Awon Oluse Agbegbe Intaneti',
      'vouchers': 'Awon Tiketi Intaneti',
      'reports': 'Awon Itan Iroyin',
      'settings': 'Awon Eto',
      'generate_vouchers': 'Se Awon Tiketi Titun',
      'connect_router': 'So Ero Pomo',
      'active_sessions': 'Awon Eniyan Ti O N Lo Lọwọlọwọ',
      'total_revenue': 'Apapọ Owo Ti A Wole',
      'cloud_sync': 'Papọ Mọ Awọsanma',
    },
    AppLanguage.igbo: {
      'dashboard': 'Mpaghara Mhazi',
      'router_fleet': 'Igwe Router',
      'hotspot_users': 'Ndị Na-eji Hotspot',
      'vouchers': 'Akwụkwọ Tiketi Intanet',
      'reports': 'Akwụkwọ Akụkọ',
      'settings': 'Ntọala',
      'generate_vouchers': 'Mepụta Tiketi Intanet',
      'connect_router': 'Jikọọ Router',
      'active_sessions': 'Ndị Na-eji Ya Ugbu a',
      'total_revenue': 'Ego Niile Betara',
      'cloud_sync': 'Ziga na Cloud',
    },
    AppLanguage.pidgin: {
      'dashboard': 'Main Dashboard',
      'router_fleet': 'All Router Network',
      'hotspot_users': 'People Wey Dey Use Wi-Fi',
      'vouchers': 'Wi-Fi Ticket Vouchers',
      'reports': 'Money & Usage Report',
      'settings': 'App Settings',
      'generate_vouchers': 'Print New Vouchers',
      'connect_router': 'Connect New Router',
      'active_sessions': 'People Wey Dey Online Now',
      'total_revenue': 'Total Money Wey Enter',
      'cloud_sync': 'Backup to Cloud',
    },
    AppLanguage.french: {
      'dashboard': 'Tableau de Bord',
      'router_fleet': 'Parc de Routeurs',
      'hotspot_users': 'Utilisateurs Hotspot',
      'vouchers': 'Tickets d\'Accès',
      'reports': 'Rapports Financiers',
      'settings': 'Paramètres',
      'generate_vouchers': 'Générer des Tickets',
      'connect_router': 'Connecter un Routeur',
      'active_sessions': 'Sessions Actives',
      'total_revenue': 'Revenu Total',
      'cloud_sync': 'Synchronisation Cloud',
    },
    AppLanguage.swahili: {
      'dashboard': 'Dawati Kuu',
      'router_fleet': 'Mtandao wa Rauta',
      'hotspot_users': 'Watumiaji wa Hotspot',
      'vouchers': 'Kadi za Mtandao',
      'reports': 'Ripoti za Mapato',
      'settings': 'Mipangilio',
      'generate_vouchers': 'Tengeneza Kadi za Intaneti',
      'connect_router': 'Unganisha Rauta',
      'active_sessions': 'Waliopo Mtandaoni Sasa',
      'total_revenue': 'Jumla ya Mapato',
      'cloud_sync': 'Hifadhi Mtandaoni',
    },
    AppLanguage.arabic: {
      'dashboard': 'لوحة التحكم',
      'router_fleet': 'أجهزة التوجيه',
      'hotspot_users': 'مستخدمو الهوتسبوت',
      'vouchers': 'قسائم الاتصال',
      'reports': 'التقارير المالية',
      'settings': 'الإعدادات',
      'generate_vouchers': 'إنشاء قسائم جديدة',
      'connect_router': 'ربط موجه جديد',
      'active_sessions': 'الجلسات النشطة',
      'total_revenue': 'إجمالي الإيرادات',
      'cloud_sync': 'المزامنة السحابية',
    },
    AppLanguage.spanish: {
      'dashboard': 'Panel Principal',
      'router_fleet': 'Flota de Enrutadores',
      'hotspot_users': 'Usuarios de Hotspot',
      'vouchers': 'Fichas de Acceso',
      'reports': 'Informes Financieros',
      'settings': 'Configuración',
      'generate_vouchers': 'Generar Fichas',
      'connect_router': 'Conectar Enrutador',
      'active_sessions': 'Sesiones Activas',
      'total_revenue': 'Ingresos Totales',
      'cloud_sync': 'Sincronización en la Nube',
    },
  };

  String translate(String key) {
    return _localizedValues[language]?[key] ??
        _localizedValues[AppLanguage.english]?[key] ??
        key;
  }
}
