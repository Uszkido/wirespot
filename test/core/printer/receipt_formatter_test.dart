import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/printer/receipt_formatter.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_entity.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_receipt.dart';

void main() {
  test('formats voucher receipts for thermal printers', () {
    final receipt = VoucherReceipt(
      voucher: VoucherEntity(
        id: 'voucher-1',
        routerId: 'router-1',
        username: 'guest001',
        password: 'secret',
        priceMinor: 10000,
        currency: 'NGN',
        generatedAt: DateTime(2026),
      ),
      businessName: 'Vexel Innovations',
      supportEmail: 'Vexelvision@gmail.com',
      supportPhone: '+234(0)7038953065',
      website: 'https://vexel-innovations.vercel.app/',
      qrPayload: 'username=guest001&password=secret',
    );

    final text = ReceiptFormatter.formatVoucher(receipt);

    expect(text, contains('Vexel Innovations'));
    expect(text, contains('Powered by WireSpot'));
    expect(text, contains('Username: guest001'));
  });
}
