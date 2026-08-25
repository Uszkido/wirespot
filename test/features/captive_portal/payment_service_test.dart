import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/captive_portal/domain/entities/payment_gateway_entity.dart';
import 'package:wirespot/features/captive_portal/domain/services/payment_service.dart';

void main() {
  group('PaymentService tests', () {
    final service = PaymentService();

    test('processCheckoutPayment generates successful transaction and voucher code', () async {
      final tx = await service.processCheckoutPayment(
        profileId: 'p_1hour',
        profileName: '1 Hour Pass',
        amount: 5.0,
        currency: 'USD',
        provider: PaymentGatewayProvider.stripe,
        reference: 'ref_123456',
        customerEmail: 'user@example.com',
      );

      expect(tx.status, equals('successful'));
      expect(tx.issuedVoucherCode, startsWith('WS-P-'));
      expect(service.transactions.length, equals(1));

      final voucher = service.createVoucherFromTransaction(tx, routerId: 'r_test');
      expect(voucher.username, equals(tx.issuedVoucherCode));
      expect(voucher.priceMinor, equals(500));
      expect(voucher.currency, equals('USD'));
    });
  });
}
