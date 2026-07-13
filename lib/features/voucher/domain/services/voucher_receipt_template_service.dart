import '../../../../core/branding/app_branding.dart';
import '../entities/voucher_entity.dart';
import '../entities/voucher_receipt.dart';
import '../entities/ticket_template.dart';
import 'voucher_qr_service.dart';

class VoucherReceiptTemplateService {
  const VoucherReceiptTemplateService(this._qrService);

  final VoucherQrService _qrService;

  VoucherReceipt build({
    required VoucherEntity voucher,
    String loginUrl = '',
    TicketTemplate template = const TicketTemplate(
      id: 'thermal_58',
      name: '58mm Thermal',
    ),
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
      templateName: template.name,
      showLogo: template.showLogo,
      showPrice: template.showPrice,
      showQrCode: template.showQrCode,
      footer: template.footer,
    );
  }
}
