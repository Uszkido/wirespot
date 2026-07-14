import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/branding/app_branding.dart';
import 'package:wirespot/features/settings/domain/entities/app_settings.dart';
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

  test('builds co-branded receipt text from operator settings', () {
    const service = VoucherReceiptTemplateService(VoucherQrService());
    final voucher = VoucherEntity(
      id: 'voucher-1',
      routerId: 'router-1',
      username: 'guest001',
      priceMinor: 50000,
      currency: 'NGN',
      validityMinutes: 60,
      generatedAt: DateTime(2026),
    );

    final receipt = service.build(
      voucher: voucher,
      settings: const AppSettingsSnapshot(
        themePreference: AppThemePreference.system,
        languageCode: 'en',
        currencyCode: 'NGN',
        notificationsEnabled: true,
        businessName: 'North Campus WiFi',
        businessEmail: 'support@north.example',
        businessPhone: '+2347000000000',
        businessWebsite: 'https://north.example',
        businessLogoPath: '/storage/emulated/0/Download/north-logo.png',
      ),
    );
    final text = receipt.toPlainText();

    expect(text, contains('North Campus WiFi'));
    expect(text, contains('support@north.example'));
    expect(text, contains('Powered by Vexel Innovations'));
    expect(text, isNot(contains(AppBranding.supportEmail)));
    expect(receipt.logoPath, contains('north-logo.png'));
  });
}
