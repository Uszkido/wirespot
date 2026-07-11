import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_entity.dart';
import 'package:wirespot/features/voucher/domain/services/voucher_qr_service.dart';
import 'package:wirespot/features/voucher/domain/services/voucher_receipt_template_service.dart';

void main() {
  test('builds Vexel-branded receipt text', () {
    const service = VoucherReceiptTemplateService(VoucherQrService());
    final voucher = VoucherEntity(
      id: 'voucher-1',
      routerId: 'router-1',
      username: 'guest001',
      password: 'secret',
      priceMinor: 50000,
      currency: 'NGN',
      validityMinutes: 60,
      generatedAt: DateTime(2026),
    );

    final receipt = service.build(voucher: voucher);
    final text = receipt.toPlainText();

    expect(text, contains('Vexel Innovations'));
    expect(text, contains('Username: guest001'));
    expect(text, contains('Password: secret'));
    expect(text, contains('Vexelvision@gmail.com'));
  });
}
