class PrinterConfigEntity {
  const PrinterConfigEntity({
    required this.id,
    required this.name,
    required this.address,
    this.paperWidthMm = 58,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String address;
  final int paperWidthMm;
  final bool isDefault;
}
