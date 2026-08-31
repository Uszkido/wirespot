import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/voucher/domain/entities/ticket_layout_config.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_entity.dart';
import 'package:wirespot/features/voucher/domain/services/voucher_thermal_ticket_service.dart';

void main() {
  group('VoucherThermalTicketService', () {
    const service = VoucherThermalTicketService();

    test('formats single thermal ticket correctly for 58mm paper', () {
      final voucher = VoucherEntity(
        id: 'v1',
        routerId: 'r1',
        username: 'WIFI-9921',
        password: 'pass123',
        priceMinor: 500,
        currency: 'USD',
        validityMinutes: 120,
        generatedAt: DateTime(2026, 1, 1),
      );

      const config = TicketLayoutConfig(
        businessName: 'Hotspot Cafe',
        paperWidthMm: 58,
      );

      final text = service.formatTicketText(voucher: voucher, config: config);

      expect(text, contains('HOTSPOT CAFE'));
      expect(text, contains('WIFI-9921'));
      expect(text, contains('pass123'));
      expect(text, contains('120 mins'));
      expect(text, contains('\$5.00'));
    });

    test('formats batch thermal tickets correctly', () {
      final vouchers = [
        VoucherEntity(
          id: 'v1',
          routerId: 'r1',
          username: 'CODE-1',
          priceMinor: 100,
          currency: 'USD',
          generatedAt: DateTime(2026, 1, 1),
        ),
        VoucherEntity(
          id: 'v2',
          routerId: 'r1',
          username: 'CODE-2',
          priceMinor: 100,
          currency: 'USD',
          generatedAt: DateTime(2026, 1, 1),
        ),
      ];

      const config = TicketLayoutConfig(paperWidthMm: 80);
      final batchText = service.formatBatchTicketText(
        vouchers: vouchers,
        config: config,
      );

      expect(batchText, contains('CODE-1'));
      expect(batchText, contains('CODE-2'));
    });
  });
}
