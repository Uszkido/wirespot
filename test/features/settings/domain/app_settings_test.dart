import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/branding/app_branding.dart';
import 'package:wirespot/features/settings/domain/entities/app_settings.dart';

void main() {
  test('settings snapshot copyWith changes selected fields', () {
    const settings = AppSettingsSnapshot(
      themePreference: AppThemePreference.system,
      languageCode: 'en',
      notificationsEnabled: true,
      businessName: AppBranding.companyName,
    );

    final next = settings.copyWith(
      themePreference: AppThemePreference.dark,
      notificationsEnabled: false,
    );

    expect(next.themePreference, AppThemePreference.dark);
    expect(next.languageCode, 'en');
    expect(next.notificationsEnabled, isFalse);
  });
}
