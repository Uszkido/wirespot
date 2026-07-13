import 'voucher_entity.dart';

class VoucherReceipt {
  const VoucherReceipt({
    required this.voucher,
    required this.businessName,
    required this.supportEmail,
    required this.supportPhone,
    required this.website,
    required this.qrPayload,
    this.templateName = '58mm Thermal',
    this.showLogo = true,
    this.showPrice = true,
    this.showQrCode = true,
    this.footer = 'Powered by Vexel Innovations',
  });

  final VoucherEntity voucher;
  final String businessName;
  final String supportEmail;
  final String supportPhone;
  final String website;
  final String qrPayload;
  final String templateName;
  final bool showLogo;
  final bool showPrice;
  final bool showQrCode;
  final String footer;

  String toPlainText() {
    final price =
        '${voucher.currency} ${(voucher.priceMinor / 100).toStringAsFixed(0)}';
    final validity = voucher.validityMinutes == null
        ? 'Unlimited'
        : '${voucher.validityMinutes} minutes';

    return [
      if (showLogo) 'Vexel Innovations Logo',
      businessName,
      'Hotspot Voucher',
      'Template: $templateName',
      'Username: ${voucher.username}',
      if (voucher.password != null) 'Password: ${voucher.password}',
      'Validity: $validity',
      if (showPrice) 'Price: $price',
      'Generated: ${voucher.generatedAt.toIso8601String()}',
      if (showQrCode) 'QR: $qrPayload',
      supportEmail,
      supportPhone,
      website,
      footer,
    ].join('\n');
  }
}
