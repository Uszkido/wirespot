import 'voucher_plan.dart';

class VoucherGenerationRequest {
  const VoucherGenerationRequest({
    required this.routerId,
    required this.plan,
    this.quantity = 1,
    this.usernamePrefix = 'WS',
    this.usernameLength = 8,
    this.passwordLength = 6,
    this.profileId,
    this.routerOsProfile,
    this.provisionOnRouter = false,
    this.note,
  });

  final String routerId;
  final VoucherPlan plan;
  final int quantity;
  final String usernamePrefix;
  final int usernameLength;
  final int passwordLength;
  final String? profileId;
  final String? routerOsProfile;
  final bool provisionOnRouter;
  final String? note;
}
