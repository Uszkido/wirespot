import '../../../../core/branding/app_branding.dart';
import '../entities/voucher_entity.dart';
import '../entities/voucher_receipt.dart';
import 'voucher_qr_service.dart';

class VoucherReceiptTemplateService {
  const VoucherReceiptTemplateService(this._qrService);

  final VoucherQrService _qrService;

  VoucherReceipt build({
    required VoucherEntity voucher,
    String loginUrl = '',
  }) {
    return VoucherReceipt(
      voucher: voucher,
      businessName: AppBranding.companyName,
      supportEmail: AppBranding.supportEmail,
      supportPhone: AppBranding.supportPhone,
      website: AppBranding.website,
      qrPayload: _qrService.hotspotLoginPayload(
        loginUrl: loginUrl,
        voucher: voucher,
      ),
    );
  }
}
