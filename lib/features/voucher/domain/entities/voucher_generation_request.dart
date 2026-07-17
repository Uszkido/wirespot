import 'voucher_plan.dart';
import 'voucher_encoding_settings.dart';

class VoucherGenerationRequest {
  const VoucherGenerationRequest({
    required this.routerId,
    required this.plan,
    this.quantity = 1,
    this.usernamePrefix = 'WS',
    this.usernameLength = 8,
    this.passwordLength = 6,
    this.priceMinor,
    this.currencyCode = 'NGN',
    this.encodingSettings = const VoucherEncodingSettings(),
    this.profileId,
    this.routerOsProfile,
    this.limitBytesTotal,
    this.provisionOnRouter = false,
    this.note,
  });

  final String routerId;
  final VoucherPlan plan;
  final int quantity;
  final String usernamePrefix;
  final int usernameLength;
  final int passwordLength;
  final int? priceMinor;
  final String currencyCode;
  final VoucherEncodingSettings encodingSettings;
  final String? profileId;
  final String? routerOsProfile;
  final int? limitBytesTotal;
  final bool provisionOnRouter;
  final String? note;
}
