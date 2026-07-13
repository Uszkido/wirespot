import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/printer/receipt_formatter.dart';
import 'package:wirespot/core/printer/printer_models.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_entity.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_receipt.dart';

void main() {
  test('formats voucher receipts for thermal printers', () {
    final receipt = _receipt();

    final text = ReceiptFormatter.formatVoucher(receipt);

    expect(text, contains('Vexel Innovations'));
    expect(text, contains('Powered by WireSpot'));
    expect(text, contains('Username:'));
    expect(text, contains('guest001'));
    expect(text, contains('SCAN / LOGIN'));
    expect(text, contains('\x1B\x61\x01'));
  });

  test('wraps long QR payload for 58mm printers', () {
    final text = ReceiptFormatter.formatVoucher(
      _receipt(
        qrPayload:
            'http://hotspot/login?username=guest001&password=secret&dst=portal',
      ),
    );

    final printableLines = text
        .split('\n')
        .where((line) => !line.startsWith('\x1B') && !line.startsWith('\x1D'));

    expect(printableLines.every((line) => line.length <= 32), isTrue);
  });

  test('uses wider dividers for 80mm printers', () {
    final text = ReceiptFormatter.formatVoucher(
      _receipt(),
      paperWidth: PrinterPaperWidth.mm80,
    );

    expect(text, contains('------------------------------------------------'));
  });
}

VoucherReceipt _receipt({
  String qrPayload = 'username=guest001&password=secret',
}) {
  return VoucherReceipt(
    voucher: VoucherEntity(
      id: 'voucher-1',
      routerId: 'router-1',
      username: 'guest001',
      password: 'secret',
      priceMinor: 10000,
      currency: 'NGN',
      validityMinutes: 60,
      generatedAt: DateTime(2026),
    ),
    businessName: 'Vexel Innovations',
    supportEmail: 'Vexelvision@gmail.com',
    supportPhone: '+234(0)7038953065',
    website: 'https://vexel-innovations.vercel.app/',
    qrPayload: qrPayload,
  );
}
