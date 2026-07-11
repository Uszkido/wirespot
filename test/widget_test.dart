import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wirespot/app.dart';
import 'package:wirespot/core/di/service_locator.dart';
import 'package:wirespot/shared/widgets/brand_logo.dart';

void main() {
  testWidgets('WireSpot renders splash screen', (tester) async {
    await configureDependencies();

    await tester.pumpWidget(const ProviderScope(child: WireSpotApp()));

    expect(find.text('WireSpot'), findsOneWidget);
    expect(find.text('Vexel Innovations hotspot operations'), findsOneWidget);
    expect(find.byType(BrandLogo), findsOneWidget);
  });
}
