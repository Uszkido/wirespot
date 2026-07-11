import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_generation_request.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_plan.dart';

void main() {
  test('stores RouterOS provisioning options', () {
    const request = VoucherGenerationRequest(
      routerId: 'router-1',
      plan: VoucherPlan(id: '1h', name: '1 Hour', validityMinutes: 60, priceMinor: 0),
      routerOsProfile: 'default',
      provisionOnRouter: true,
    );

    expect(request.routerOsProfile, 'default');
    expect(request.provisionOnRouter, isTrue);
  });
}
