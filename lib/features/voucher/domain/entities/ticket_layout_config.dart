class TicketLayoutConfig {
  const TicketLayoutConfig({
    this.businessName = 'WireSpot Hotspot',
    this.headline = 'WIFI VOUCHER',
    this.footerNote = 'Thank you for connecting! Keep this ticket safe.',
    this.paperWidthMm = 58,
    this.showQrCode = true,
    this.qrScale = 4,
    this.currencySymbol = '\$',
    this.showPrice = true,
    this.showExpiration = true,
  });

  factory TicketLayoutConfig.defaultConfig() => const TicketLayoutConfig();

  final String businessName;
  final String headline;
  final String footerNote;
  final int paperWidthMm; // 58 or 80
  final bool showQrCode;
  final int qrScale;
  final String currencySymbol;
  final bool showPrice;
  final bool showExpiration;

  String get headerSlogan => headline;
  String get footerText => footerNote;

  int get maxCharWidth => paperWidthMm == 80 ? 48 : 32;

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'headline': headline,
      'footerNote': footerNote,
      'paperWidthMm': paperWidthMm,
      'showQrCode': showQrCode,
      'qrScale': qrScale,
      'currencySymbol': currencySymbol,
      'showPrice': showPrice,
      'showExpiration': showExpiration,
    };
  }

  factory TicketLayoutConfig.fromJson(Map<String, dynamic> json) {
    return TicketLayoutConfig(
      businessName: json['businessName'] as String? ?? 'WireSpot Hotspot',
      headline: json['headline'] as String? ?? 'WIFI VOUCHER',
      footerNote:
          json['footerNote'] as String? ??
          'Thank you for connecting! Keep this ticket safe.',
      paperWidthMm: json['paperWidthMm'] as int? ?? 58,
      showQrCode: json['showQrCode'] as bool? ?? true,
      qrScale: json['qrScale'] as int? ?? 4,
      currencySymbol: json['currencySymbol'] as String? ?? '\$',
      showPrice: json['showPrice'] as bool? ?? true,
      showExpiration: json['showExpiration'] as bool? ?? true,
    );
  }

  TicketLayoutConfig copyWith({
    String? businessName,
    String? headline,
    String? footerNote,
    int? paperWidthMm,
    bool? showQrCode,
    int? qrScale,
    String? currencySymbol,
    bool? showPrice,
    bool? showExpiration,
  }) {
    return TicketLayoutConfig(
      businessName: businessName ?? this.businessName,
      headline: headline ?? this.headline,
      footerNote: footerNote ?? this.footerNote,
      paperWidthMm: paperWidthMm ?? this.paperWidthMm,
      showQrCode: showQrCode ?? this.showQrCode,
      qrScale: qrScale ?? this.qrScale,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      showPrice: showPrice ?? this.showPrice,
      showExpiration: showExpiration ?? this.showExpiration,
    );
  }
}
