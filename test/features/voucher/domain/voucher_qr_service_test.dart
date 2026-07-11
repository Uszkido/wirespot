import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_entity.dart';
import 'package:wirespot/features/voucher/domain/services/voucher_qr_service.dart';

void main() {
  test('builds hotspot login QR payload', () {
    const service = VoucherQrService();
    final voucher = VoucherEntity(
      id: 'voucher-1',
      routerId: 'router-1',
      username: 'guest 1',
      password: 'pass/1',
      priceMinor: 0,
      currency: 'NGN',
      generatedAt: DateTime(2026),
    );

    final payload = service.hotspotLoginPayload(
      loginUrl: 'http://hotspot/login',
      voucher: voucher,
    );

    expect(payload, 'http://hotspot/login?username=guest%201&password=pass%2F1');
  });
}
