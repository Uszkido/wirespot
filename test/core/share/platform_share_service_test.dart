import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/share/platform_share_service.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_entity.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_receipt.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test.share');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('shares selected vouchers as one labelled message', () async {
    const service = PlatformShareService(channel: channel);

    await service.shareVoucherReceipts([
      _receipt('guest001'),
      _receipt('guest002'),
    ]);

    final arguments = Map<Object?, Object?>.from(calls.single.arguments as Map);
    expect(calls.single.method, 'shareText');
    expect(arguments['subject'], 'WireSpot vouchers (2)');
    expect(arguments['text'], contains('Username: guest001'));
    expect(arguments['text'], contains('Username: guest002'));
    expect(arguments['text'], contains('---'));
  });

  test('does not invoke the share sheet for an empty selection', () async {
    const service = PlatformShareService(channel: channel);

    await service.shareVoucherReceipts(const []);

    expect(calls, isEmpty);
  });
}

VoucherReceipt _receipt(String username) {
  return VoucherReceipt(
    voucher: VoucherEntity(
      id: username,
      routerId: 'router-1',
      username: username,
      priceMinor: 50000,
      currency: 'NGN',
      generatedAt: DateTime(2026),
    ),
    businessName: 'WireSpot',
    supportEmail: 'support@example.com',
    supportPhone: '+2347000000000',
    website: 'https://example.com',
    qrPayload: 'username=$username',
  );
}
