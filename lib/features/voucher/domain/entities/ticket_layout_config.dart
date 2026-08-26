class TicketLayoutConfig {
  const TicketLayoutConfig({
    required this.headerSlogan,
    required this.footerText,
    required this.showQrCode,
    required this.qrCodeSize,
    required this.showBarcode,
    required this.fontScale,
    required this.paperWidthMm,
  });

  final String headerSlogan;
  final String footerText;
  final bool showQrCode;
  final int qrCodeSize;
  final bool showBarcode;
  final double fontScale;
  final int paperWidthMm;

  factory TicketLayoutConfig.defaultConfig() {
    return const TicketLayoutConfig(
      headerSlogan: 'Connecting Possibilities',
      footerText: 'Thank you for using WireSpot Hotspot!',
      showQrCode: true,
      qrCodeSize: 120,
      showBarcode: true,
      fontScale: 1.0,
      paperWidthMm: 58,
    );
  }
}
