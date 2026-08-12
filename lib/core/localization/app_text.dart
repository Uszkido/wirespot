class AppText {
  const AppText(this.languageCode);

  final String languageCode;

  String get settings => _pick(en: 'Settings', fr: 'Parametres', ha: 'Saituna');

  String get dashboard =>
      _pick(en: 'Dashboard', fr: 'Tableau de bord', ha: 'Dashboard');

  String get routers => _pick(en: 'Routers', fr: 'Routeurs', ha: 'Rautoci');

  String get hotspot => _pick(en: 'Hotspot', fr: 'Hotspot', ha: 'Hotspot');

  String get vouchers => _pick(en: 'Vouchers', fr: 'Coupons', ha: 'Tikiti');

  String get reports => _pick(en: 'Reports', fr: 'Rapports', ha: 'Rahotanni');

  String get refresh => _pick(en: 'Refresh', fr: 'Actualiser', ha: 'Sabunta');

  String get retry => _pick(en: 'Retry', fr: 'Reessayer', ha: 'Sake gwadawa');

  String get addRouter =>
      _pick(en: 'Add router', fr: 'Ajouter routeur', ha: 'Kara rauta');

  String get edit => _pick(en: 'Edit', fr: 'Modifier', ha: 'Gyara');

  String get delete => _pick(en: 'Delete', fr: 'Supprimer', ha: 'Goge');

  String get cancel => _pick(en: 'Cancel', fr: 'Annuler', ha: 'Soke');

  String get save => _pick(en: 'Save', fr: 'Enregistrer', ha: 'Ajiye');

  String get create => _pick(en: 'Create', fr: 'Creer', ha: 'Kirkira');

  String get apply => _pick(en: 'Apply', fr: 'Appliquer', ha: 'Aiwatar');

  String get close => _pick(en: 'Close', fr: 'Fermer', ha: 'Rufe');

  String get onlineUsers => _pick(
    en: 'Online users',
    fr: 'Utilisateurs en ligne',
    ha: 'Masu amfani online',
  );

  String get todaySales =>
      _pick(en: 'Today sales', fr: 'Ventes du jour', ha: 'Sayarwar yau');

  String get memory => _pick(en: 'Memory', fr: 'Memoire', ha: 'Memory');

  String get routerHealth =>
      _pick(en: 'Router Health', fr: 'Sante du routeur', ha: 'Lafiyar rauta');

  String get interfaces =>
      _pick(en: 'Interfaces', fr: 'Interfaces', ha: 'Interfaces');

  String get support => _pick(en: 'Support', fr: 'Support', ha: 'Taimako');

  String get online => _pick(en: 'Online', fr: 'En ligne', ha: 'Online');

  String get apiOffline =>
      _pick(en: 'API offline', fr: 'API hors ligne', ha: 'API baya online');

  String get version => _pick(en: 'Version', fr: 'Version', ha: 'Siga');

  String get board => _pick(en: 'Board', fr: 'Carte', ha: 'Allo');

  String get uptime =>
      _pick(en: 'Uptime', fr: 'Duree active', ha: 'Lokacin aiki');

  String get freeMemory =>
      _pick(en: 'Free memory', fr: 'Memoire libre', ha: 'Memory da ya rage');

  String get temperature =>
      _pick(en: 'Temperature', fr: 'Temperature', ha: 'Zafi');

  String get running => _pick(en: 'Running', fr: 'Actif', ha: 'Yana aiki');

  String get down => _pick(en: 'Down', fr: 'Arrete', ha: 'Ya tsaya');

  String get noInterfaces => _pick(
    en: 'No interfaces reported.',
    fr: 'Aucune interface signalee.',
    ha: 'Babu interface da aka nuna.',
  );

  String get connectVpnForHealth => _pick(
    en: 'Connect WireGuard and refresh to load RouterOS health.',
    fr: 'Connectez WireGuard puis actualisez pour charger la sante RouterOS.',
    ha: 'Ha da WireGuard sannan ka sabunta domin ganin lafiyar RouterOS.',
  );

  String get interfaceDataAfterConnection => _pick(
    en: 'Interface data appears after the VPN is connected and RouterOS API responds.',
    fr: 'Les donnees interface apparaissent apres connexion VPN et reponse de RouterOS API.',
    ha: 'Bayanan interface zai bayyana bayan VPN ya hade kuma RouterOS API ya amsa.',
  );

  String get pressBackAgain => _pick(
    en: 'Press back again to exit WireSpot.',
    fr: 'Appuyez encore sur retour pour quitter WireSpot.',
    ha: 'Danna baya sau daya kuma don fita daga WireSpot.',
  );

  String get addRouterMessage => _pick(
    en: 'Connect a MikroTik router before viewing dashboard data.',
    fr: 'Connectez un routeur MikroTik avant de voir le tableau de bord.',
    ha: 'Hada MikroTik rauta kafin ganin bayanan dashboard.',
  );

  String get noRoutersYet =>
      _pick(en: 'No routers yet', fr: 'Aucun routeur', ha: 'Babu rauta tukuna');

  String get noRoutersMessage => _pick(
    en: 'Add your first MikroTik router to manage hotspot users.',
    fr: 'Ajoutez votre premier routeur MikroTik pour gerer les utilisateurs hotspot.',
    ha: 'Kara MikroTik rauta na farko domin sarrafa masu amfani da hotspot.',
  );

  String get couldNotLoadRouters => _pick(
    en: 'Could not load routers',
    fr: 'Impossible de charger les routeurs',
    ha: 'An kasa loda rautoci',
  );

  String get routerActions =>
      _pick(en: 'Router actions', fr: 'Actions routeur', ha: 'Ayyukan rauta');

  String get testConnection =>
      _pick(en: 'Test connection', fr: 'Tester connexion', ha: 'Gwada hadewa');

  String get remoteTunnel =>
      _pick(en: 'Remote tunnel', fr: 'Tunnel distant', ha: 'Remote tunnel');

  String get testingRouterConnection => _pick(
    en: 'Testing router connection...',
    fr: 'Test de connexion routeur...',
    ha: 'Ana gwada hadewar rauta...',
  );

  String get routerConnectionSuccessful => _pick(
    en: 'Router connection successful.',
    fr: 'Connexion routeur reussie.',
    ha: 'Hadewar rauta ta yi nasara.',
  );

  String get routerConnectionFailed => _pick(
    en: 'Router connection failed.',
    fr: 'Connexion routeur echouee.',
    ha: 'Hadewar rauta ta kasa.',
  );

  String connectionTestFailed(Object error) => _pick(
    en: 'Connection test failed: $error',
    fr: 'Test de connexion echoue: $error',
    ha: 'Gwajin hadewa ya kasa: $error',
  );

  String get deleteRouterQuestion => _pick(
    en: 'Delete router?',
    fr: 'Supprimer routeur?',
    ha: 'A goge rauta?',
  );

  String removeRouterMessage(String name) => _pick(
    en: 'Remove $name and its saved credentials.',
    fr: 'Supprimer $name et ses identifiants enregistres.',
    ha: 'Goge $name da bayanan shigarsa da aka ajiye.',
  );

  String get routerDeleted => _pick(
    en: 'Router deleted.',
    fr: 'Routeur supprime.',
    ha: 'An goge rauta.',
  );

  String get dashboardUnavailable => _pick(
    en: 'Dashboard unavailable',
    fr: 'Tableau de bord indisponible',
    ha: 'Dashboard baya samuwa',
  );

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

  String get permissionReadiness => _pick(
    en: 'Permission readiness',
    fr: 'Permissions pretes',
    ha: 'Shirin izini',
  );

  String get permissionReadinessSubtitle => _pick(
    en: 'Request VPN consent and Bluetooth access.',
    fr: 'Demander le consentement VPN et acces Bluetooth.',
    ha: 'Nemi izinin VPN da Bluetooth.',
  );

  String get wireGuardVpn =>
      _pick(en: 'WireGuard VPN', fr: 'VPN WireGuard', ha: 'WireGuard VPN');

  String get wireGuardVpnSubtitle => _pick(
    en: 'Import tunnels, connect, view status, and logs.',
    fr: 'Importer tunnels, connecter, voir etat et journaux.',
    ha: 'Shigo da tunnels, hade, duba matsayi da logs.',
  );

  String get scheduler =>
      _pick(en: 'Scheduler', fr: 'Planificateur', ha: 'Mai tsara lokaci');

  String scheduledTaskLabel(String typeName, String fallback) {
    return switch (typeName) {
      'activeSessionRefresh' => _pick(
        en: 'Active session refresh',
        fr: 'Actualiser sessions actives',
        ha: 'Sabunta sessions masu aiki',
      ),
      'expiredUserCleanup' => _pick(
        en: 'Expired user cleanup',
        fr: 'Nettoyage utilisateurs expires',
        ha: 'Share masu amfani da suka kare',
      ),
      'voucherCleanup' => _pick(
        en: 'Voucher cleanup',
        fr: 'Nettoyage coupons',
        ha: 'Share tikiti',
      ),
      'dailySalesSummary' => _pick(
        en: 'Daily sales summary',
        fr: 'Resume ventes journalieres',
        ha: 'Takaitaccen sayarwar yau',
      ),
      'databaseBackup' => _pick(
        en: 'Database backup',
        fr: 'Sauvegarde base de donnees',
        ha: 'Ajiyar database',
      ),
      _ => fallback,
    };
  }

  String everyMinutes(int minutes) => _pick(
    en: 'Every $minutes minutes',
    fr: 'Toutes les $minutes minutes',
    ha: 'Kowane minti $minutes',
  );

  String get lastRun => _pick(
    en: 'Last run',
    fr: 'Derniere execution',
    ha: 'Gudanarwa ta karshe',
  );

  String get premium => _pick(en: 'Premium', fr: 'Premium', ha: 'Premium');

  String get runDueTasksNow => _pick(
    en: 'Run due tasks now',
    fr: 'Executer les taches dues',
    ha: 'Gudanar da ayyukan da suka kai',
  );

  String get noSchedulerTasksDue => _pick(
    en: 'No scheduler tasks are due now.',
    fr: 'Aucune tache planifiee due maintenant.',
    ha: 'Babu aikin scheduler da ya kai yanzu.',
  );

  String ranSchedulerTasks(int count) => _pick(
    en: 'Ran $count scheduler task(s).',
    fr: '$count tache(s) executee(s).',
    ha: 'An gudanar da aiki $count na scheduler.',
  );

  String get noRouterAvailable => _pick(
    en: 'No router available',
    fr: 'Aucun routeur disponible',
    ha: 'Babu rauta',
  );

  String get addRouterBeforeVouchers => _pick(
    en: 'Add a router before generating vouchers.',
    fr: 'Ajoutez un routeur avant de creer des coupons.',
    ha: 'Kara rauta kafin kirkirar tikiti.',
  );

  String get encodingUnavailable => _pick(
    en: 'Encoding unavailable',
    fr: 'Encodage indisponible',
    ha: 'Tsarin encoding baya samuwa',
  );

  String get generateVouchers => _pick(
    en: 'Generate vouchers',
    fr: 'Creer des coupons',
    ha: 'Kirkiri tikiti',
  );

  String get router => _pick(en: 'Router', fr: 'Routeur', ha: 'Rauta');

  String get plan => _pick(en: 'Plan', fr: 'Forfait', ha: 'Tsari');

  String get userCodeMode => _pick(
    en: 'User code mode',
    fr: 'Mode code utilisateur',
    ha: 'Nauin lambar mai amfani',
  );

  String get usernamePassword => _pick(
    en: 'Username + password',
    fr: 'Nom utilisateur + mot de passe',
    ha: 'Sunan mai amfani + kalmar sirri',
  );

  String get usernameOnly => _pick(
    en: 'Username only',
    fr: 'Nom utilisateur seul',
    ha: 'Sunan mai amfani kadai',
  );

  String get usernameAsPinOnly => _pick(
    en: 'Username as PIN only',
    fr: 'Nom utilisateur comme PIN',
    ha: 'Sunan mai amfani a matsayin PIN',
  );

  String get quantity => _pick(en: 'Quantity', fr: 'Quantite', ha: 'Yawa');

  String get userPrefix => _pick(
    en: 'User prefix',
    fr: 'Prefixe utilisateur',
    ha: 'Prefix na mai amfani',
  );

  String get pinDigits =>
      _pick(en: 'PIN digits', fr: 'Chiffres PIN', ha: 'Lambobin PIN');

  String get usernameLength => _pick(
    en: 'Username length',
    fr: 'Longueur nom utilisateur',
    ha: 'Tsawon sunan mai amfani',
  );

  String get passwordLength => _pick(
    en: 'Password length',
    fr: 'Longueur mot de passe',
    ha: 'Tsawon kalmar sirri',
  );

  String get price => _pick(en: 'Price', fr: 'Prix', ha: 'Farashi');

  String get dataLimit =>
      _pick(en: 'Data limit', fr: 'Limite donnees', ha: 'Iyakar data');

  String get createRouterOsUsers => _pick(
    en: 'Create RouterOS users',
    fr: 'Creer utilisateurs RouterOS',
    ha: 'Kirkiri masu amfani a RouterOS',
  );

  String get routerOsAccessRequired => _pick(
    en: 'Requires WireGuard and RouterOS API access.',
    fr: 'Necessite WireGuard et acces API RouterOS.',
    ha: 'Yana bukatar WireGuard da damar RouterOS API.',
  );

  String get routerOsProfile => _pick(
    en: 'RouterOS profile',
    fr: 'Profil RouterOS',
    ha: 'Profile na RouterOS',
  );

  String get routerOsDefaultProfileHint => _pick(
    en: 'Leave blank to use RouterOS default.',
    fr: 'Laissez vide pour utiliser la valeur par defaut RouterOS.',
    ha: 'Barshi babu komai domin amfani da default na RouterOS.',
  );

  String get generating =>
      _pick(en: 'Generating...', fr: 'Creation...', ha: 'Ana kirkira...');

  String get generate => _pick(en: 'Generate', fr: 'Creer', ha: 'Kirkira');

  String vouchersGenerated(int count) => _pick(
    en: '$count voucher(s) generated.',
    fr: '$count coupon(s) cree(s).',
    ha: 'An kirkiri tikiti $count.',
  );

  String couldNotGenerateVouchers(Object error) => _pick(
    en: 'Could not generate vouchers: $error',
    fr: 'Impossible de creer les coupons: $error',
    ha: 'An kasa kirkirar tikiti: $error',
  );

  String get noVoucherHistory => _pick(
    en: 'No voucher history',
    fr: 'Aucun historique coupons',
    ha: 'Babu tarihin tikiti',
  );

  String get voucherHistoryMessage => _pick(
    en: 'Generated vouchers will appear here.',
    fr: 'Les coupons crees apparaitront ici.',
    ha: 'Tikiti da aka kirkira zasu bayyana anan.',
  );

  String get history => _pick(en: 'History', fr: 'Historique', ha: 'Tarihi');

  String get couldNotLoadVouchers => _pick(
    en: 'Could not load vouchers',
    fr: 'Impossible de charger les coupons',
    ha: 'An kasa loda tikiti',
  );

  String _pick({required String en, required String fr, required String ha}) {
    return switch (languageCode) {
      'fr' => fr,
      'ha' => ha,
      _ => en,
    };
  }
}
