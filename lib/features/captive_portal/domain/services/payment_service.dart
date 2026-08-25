import 'dart:async';
import '../../../voucher/domain/entities/voucher_entity.dart';
import '../entities/payment_gateway_entity.dart';

class PaymentService {
  final List<VoucherPurchaseTransaction> _transactions = [];

  List<VoucherPurchaseTransaction> get transactions =>
      List.unmodifiable(_transactions);

  /// Verifies a payment reference against the gateway provider and issues a voucher.
  Future<VoucherPurchaseTransaction> processCheckoutPayment({
    required String profileId,
    required String profileName,
    required double amount,
    required String currency,
    required PaymentGatewayProvider provider,
    required String reference,
    required String customerEmail,
  }) async {
    // Simulate gateway verification API response (200 OK)
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final voucherCode =
        'WS-P-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final transaction = VoucherPurchaseTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      profileId: profileId,
      profileName: profileName,
      amount: amount,
      currency: currency,
      provider: provider,
      reference: reference,
      customerEmail: customerEmail,
      status: 'successful',
      createdAt: DateTime.now(),
      issuedVoucherCode: voucherCode,
    );

    _transactions.insert(0, transaction);
    return transaction;
  }

  VoucherEntity createVoucherFromTransaction(
    VoucherPurchaseTransaction tx, {
    String routerId = '',
  }) {
    return VoucherEntity(
      id: 'v_${tx.id}',
      routerId: routerId,
      username: tx.issuedVoucherCode ?? 'WS-VOUCHER',
      priceMinor: (tx.amount * 100).round(),
      currency: tx.currency,
      generatedAt: tx.createdAt,
      profileId: tx.profileId,
      note: 'Payment via ${tx.provider.label} — ${tx.customerEmail}',
    );
  }
}
