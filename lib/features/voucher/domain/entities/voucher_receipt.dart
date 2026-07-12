import 'voucher_entity.dart';

class VoucherReceipt {
  const VoucherReceipt({
    required this.voucher,
    required this.businessName,
    required this.supportEmail,
    required this.supportPhone,
    required this.website,
    required this.qrPayload,
  });

  final VoucherEntity voucher;
  final String businessName;
  final String supportEmail;
  final String supportPhone;
  final String website;
  final String qrPayload;

  String toPlainText() {
    final price =
        '${voucher.currency} ${(voucher.priceMinor / 100).toStringAsFixed(0)}';
    final validity = voucher.validityMinutes == null
        ? 'Unlimited'
        : '${voucher.validityMinutes} minutes';

    return [
      businessName,
      'Hotspot Voucher',
      'Username: ${voucher.username}',
      if (voucher.password != null) 'Password: ${voucher.password}',
      'Validity: $validity',
      'Price: $price',
      'Generated: ${voucher.generatedAt.toIso8601String()}',
      'QR: $qrPayload',
      supportEmail,
      supportPhone,
      website,
    ].join('\n');
  }
}
