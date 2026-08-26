class CaptivePortalTemplate {
  const CaptivePortalTemplate({
    required this.id,
    required this.name,
    required this.businessName,
    required this.welcomeHeadline,
    required this.tagline,
    required this.primaryColorHex,
    required this.backgroundColorHex,
    required this.cardColorHex,
    required this.textColorHex,
    required this.logoUrl,
    required this.termsAndConditions,
    required this.loginButtonLabel,
    required this.showVoucherInput,
    required this.showMemberInput,
    required this.supportContact,
  });

  final String id;
  final String name;
  final String businessName;
  final String welcomeHeadline;
  final String tagline;
  final String primaryColorHex;
  final String backgroundColorHex;
  final String cardColorHex;
  final String textColorHex;
  final String logoUrl;
  final String termsAndConditions;
  final String loginButtonLabel;
  final bool showVoucherInput;
  final bool showMemberInput;
  final String supportContact;

  factory CaptivePortalTemplate.defaultTemplate() {
    return const CaptivePortalTemplate(
      id: 'default-template',
      name: 'Modern Glassmorphism',
      businessName: 'WireSpot Hotspot',
      welcomeHeadline: 'Welcome to High-Speed Wi-Fi',
      tagline: 'Enter your voucher code or login credentials to connect.',
      primaryColorHex: '#0284c7',
      backgroundColorHex: '#0f172a',
      cardColorHex: '#1e293b',
      textColorHex: '#f8fafc',
      logoUrl: '',
      termsAndConditions:
          'By logging in, you agree to our Terms of Service & Privacy Policy.',
      loginButtonLabel: 'Connect Now',
      showVoucherInput: true,
      showMemberInput: true,
      supportContact: 'Support: +234(0)7038953065',
    );
  }

  CaptivePortalTemplate copyWith({
    String? id,
    String? name,
    String? businessName,
    String? welcomeHeadline,
    String? tagline,
    String? primaryColorHex,
    String? backgroundColorHex,
    String? cardColorHex,
    String? textColorHex,
    String? logoUrl,
    String? termsAndConditions,
    String? loginButtonLabel,
    bool? showVoucherInput,
    bool? showMemberInput,
    String? supportContact,
  }) {
    return CaptivePortalTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      welcomeHeadline: welcomeHeadline ?? this.welcomeHeadline,
      tagline: tagline ?? this.tagline,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      cardColorHex: cardColorHex ?? this.cardColorHex,
      textColorHex: textColorHex ?? this.textColorHex,
      logoUrl: logoUrl ?? this.logoUrl,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      loginButtonLabel: loginButtonLabel ?? this.loginButtonLabel,
      showVoucherInput: showVoucherInput ?? this.showVoucherInput,
      showMemberInput: showMemberInput ?? this.showMemberInput,
      supportContact: supportContact ?? this.supportContact,
    );
  }
}
