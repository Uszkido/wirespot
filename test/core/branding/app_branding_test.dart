import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/branding/app_branding.dart';

void main() {
  test('WireSpot co-branding is configured', () {
    expect(AppBranding.appName, 'WireSpot');
    expect(AppBranding.companyName, 'Vexel Innovations');
    expect(AppBranding.collaboratorName, 'TechNova Technologies');
    expect(AppBranding.supportEmail, 'Vexelvision@gmail.com');
    expect(AppBranding.supportPhone, '+234(0)7038953065');
    expect(AppBranding.website, 'https://vexel-innovations.vercel.app/');
    expect(AppBranding.logoAsset, 'assets/images/wirespot_mark.jpg');
  });
}
