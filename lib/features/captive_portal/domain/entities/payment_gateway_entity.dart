enum PaymentGatewayProvider {
  paystack,
  flutterwave,
  stripe,
  manualCash;

  String get label {
    switch (this) {
      case PaymentGatewayProvider.paystack:
        return 'Paystack';
      case PaymentGatewayProvider.flutterwave:
        return 'Flutterwave';
      case PaymentGatewayProvider.stripe:
        return 'Stripe';
      case PaymentGatewayProvider.manualCash:
        return 'Manual / POS Cash';
    }
  }

  String get currencyDefault {
    switch (this) {
      case PaymentGatewayProvider.paystack:
        return 'NGN';
      case PaymentGatewayProvider.flutterwave:
        return 'USD';
      case PaymentGatewayProvider.stripe:
        return 'USD';
      case PaymentGatewayProvider.manualCash:
        return 'USD';
    }
  }
}

class PaymentGatewayConfig {
  const PaymentGatewayConfig({
    required this.provider,
    required this.publicKey,
    required this.secretKey,
    this.webhookSecret,
    this.isEnabled = true,
  });

  final PaymentGatewayProvider provider;
  final String publicKey;
  final String secretKey;
  final String? webhookSecret;
  final bool isEnabled;
}

class VoucherPurchaseTransaction {
  const VoucherPurchaseTransaction({
    required this.id,
    required this.profileId,
    required this.profileName,
    required this.amount,
    required this.currency,
    required this.provider,
    required this.reference,
    required this.customerEmail,
    required this.status,
    required this.createdAt,
    this.issuedVoucherCode,
  });

  final String id;
  final String profileId;
  final String profileName;
  final double amount;
  final String currency;
  final PaymentGatewayProvider provider;
  final String reference;
  final String customerEmail;
  final String status;
  final DateTime createdAt;
  final String? issuedVoucherCode;
}
