import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/printer/platform_printer_service.dart';
import 'package:wirespot/core/printer/printer_models.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_entity.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_receipt.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test.printer');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return {'success': true, 'message': 'ok'};
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('passes logo asset when receipt shows logo', () async {
    const service = PlatformPrinterService(channel: channel);

    await service.printVoucherReceipt(
      printer: const BluetoothPrinterDevice(
        name: 'Printer',
        address: 'AA:BB:CC:DD:EE:FF',
      ),
      receipt: _receipt(showLogo: true),
    );

    final arguments = Map<Object?, Object?>.from(calls.single.arguments as Map);
    expect(arguments['logoAsset'], 'assets/images/vexel_logo.png');
    expect(arguments['logoFile'], isEmpty);
  });

  test('omits logo asset when receipt hides logo', () async {
    const service = PlatformPrinterService(channel: channel);

    await service.printVoucherReceipt(
      printer: const BluetoothPrinterDevice(
        name: 'Printer',
        address: 'AA:BB:CC:DD:EE:FF',
      ),
      receipt: _receipt(showLogo: false),
    );

    final arguments = Map<Object?, Object?>.from(calls.single.arguments as Map);
    expect(arguments['logoAsset'], isEmpty);
    expect(arguments['logoFile'], isEmpty);
  });
}

VoucherReceipt _receipt({required bool showLogo}) {
  return VoucherReceipt(
    voucher: VoucherEntity(
      id: 'voucher-1',
      routerId: 'router-1',
      username: 'guest001',
      password: 'secret',
      priceMinor: 10000,
      currency: 'NGN',
      validityMinutes: 60,
      generatedAt: DateTime(2026),
    ),
    businessName: 'Vexel Innovations',
    supportEmail: 'Vexelvision@gmail.com',
    supportPhone: '+234(0)7038953065',
    website: 'https://vexel-innovations.vercel.app/',
    qrPayload: 'username=guest001&password=secret',
    showLogo: showLogo,
  );
}
