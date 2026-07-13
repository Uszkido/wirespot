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

  TicketTemplate copyWith({
    String? id,
    String? name,
    String? description,
    int? paperWidthMm,
    bool? showLogo,
    bool? showQrCode,
    bool? showPrice,
    String? footer,
  }) {
    return TicketTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      paperWidthMm: paperWidthMm ?? this.paperWidthMm,
      showLogo: showLogo ?? this.showLogo,
      showQrCode: showQrCode ?? this.showQrCode,
      showPrice: showPrice ?? this.showPrice,
      footer: footer ?? this.footer,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'paperWidthMm': paperWidthMm,
      'showLogo': showLogo,
      'showQrCode': showQrCode,
      'showPrice': showPrice,
      'footer': footer,
    };
  }

  factory TicketTemplate.fromJson(Map<String, Object?> json) {
    final paperWidth = json['paperWidthMm'] as int? ?? 58;
    return TicketTemplate(
      id: json['id'] as String? ?? defaults.first.id,
      name: json['name'] as String? ?? defaults.first.name,
      description: json['description'] as String? ?? '',
      paperWidthMm: paperWidth == 80 ? 80 : 58,
      showLogo: json['showLogo'] as bool? ?? true,
      showQrCode: json['showQrCode'] as bool? ?? true,
      showPrice: json['showPrice'] as bool? ?? true,
      footer: json['footer'] as String? ?? 'Powered by Vexel Innovations',
    );
  }

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

  @override
  bool operator ==(Object other) {
    return other is TicketTemplate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
