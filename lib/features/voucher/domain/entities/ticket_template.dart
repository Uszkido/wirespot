class TicketTemplate {
  const TicketTemplate({
    required this.id,
    required this.name,
    this.description = '',
    this.paperWidthMm = 58,
    this.showLogo = true,
    this.showQrCode = true,
    this.showPrice = true,
    this.footer = 'Powered by Vexel Innovations',
  });

  final String id;
  final String name;
  final String description;
  final int paperWidthMm;
  final bool showLogo;
  final bool showQrCode;
  final bool showPrice;
  final String footer;

  static const defaults = [
    TicketTemplate(
      id: 'thermal_58',
      name: '58mm Thermal',
      description: 'Compact receipt for small Bluetooth printers.',
    ),
    TicketTemplate(
      id: 'thermal_80',
      name: '80mm Thermal',
      description: 'Wider receipt with more breathing room.',
      paperWidthMm: 80,
    ),
    TicketTemplate(
      id: 'qr_compact',
      name: 'QR Compact',
      description: 'Short voucher focused on username, password, and QR.',
      showLogo: false,
    ),
  ];

  static TicketTemplate byId(String? id) {
    return defaults.firstWhere(
      (template) => template.id == id,
      orElse: () => defaults.first,
    );
  }
}
