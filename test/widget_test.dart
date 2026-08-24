import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirespot/app.dart';
import 'package:wirespot/core/branding/app_branding.dart';
import 'package:wirespot/core/di/service_locator.dart';
import 'package:wirespot/shared/widgets/brand_logo.dart';

void main() {
  testWidgets('WireSpot renders splash screen', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    if (!sl.isRegistered<Dio>()) {
      await configureDependencies();
    }

    await tester.pumpWidget(const ProviderScope(child: WireSpotApp()));

    expect(find.text(AppBranding.appName), findsOneWidget);
    expect(find.text(AppBranding.partnershipLine), findsOneWidget);
    expect(find.byType(BrandLogo), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1000));
  });
}
