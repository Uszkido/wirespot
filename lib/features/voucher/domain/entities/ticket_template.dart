class TicketTemplate {
  const TicketTemplate({
    required this.id,
    required this.name,
    this.paperWidthMm = 58,
    this.showLogo = true,
    this.showQrCode = true,
    this.showPrice = true,
    this.footer = 'Powered by Vexel Innovations',
  });

  final String id;
  final String name;
  final int paperWidthMm;
  final bool showLogo;
  final bool showQrCode;
  final bool showPrice;
  final String footer;

  static const defaults = [
    TicketTemplate(id: 'thermal_58', name: '58mm Thermal'),
    TicketTemplate(id: 'thermal_80', name: '80mm Thermal', paperWidthMm: 80),
    TicketTemplate(id: 'qr_compact', name: 'QR Compact', showLogo: false),
  ];
}
