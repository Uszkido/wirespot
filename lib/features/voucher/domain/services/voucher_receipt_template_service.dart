import '../../../../core/branding/app_branding.dart';
import '../../../settings/domain/entities/app_settings.dart';
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
    AppSettingsSnapshot? settings,
    TicketTemplate template = const TicketTemplate(
      id: 'thermal_58',
      name: '58mm Thermal',
    ),
  }) {
    return VoucherReceipt(
      voucher: voucher,
      businessName: settings?.businessName ?? AppBranding.companyName,
      supportEmail: settings?.businessEmail ?? AppBranding.supportEmail,
      supportPhone: settings?.businessPhone ?? AppBranding.supportPhone,
      website: settings?.businessWebsite ?? AppBranding.website,
      qrPayload: _qrService.hotspotLoginPayload(
        loginUrl: loginUrl,
        voucher: voucher,
      ),
      templateName: template.name,
      showLogo: template.showLogo,
      showPrice: template.showPrice,
      showQrCode: template.showQrCode,
      footer: template.footer,
      logoPath: settings?.businessLogoPath ?? '',
    );
  }
}
