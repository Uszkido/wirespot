import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/authentication/domain/entities/operator_role.dart';
import 'package:wirespot/features/diagnostics/domain/services/network_security_service.dart';
import 'package:wirespot/features/hotspot/domain/entities/captive_portal_template.dart';
import 'package:wirespot/features/hotspot/domain/services/captive_portal_service.dart';
import 'package:wirespot/features/reports/domain/entities/revenue_summary.dart';
import 'package:wirespot/features/reports/domain/entities/sale_entity.dart';
import 'package:wirespot/features/reports/domain/services/telemetry_analytics_service.dart';
import 'package:wirespot/features/voucher/domain/entities/ticket_layout_config.dart';
import 'package:wirespot/features/voucher/domain/entities/voucher_entity.dart';
import 'package:wirespot/features/voucher/domain/services/voucher_print_service.dart';

import 'package:wirespot/features/hotspot/domain/entities/hotspot_active_session_entity.dart';

void main() {
  group('CaptivePortalService', () {
    test('generates MikroTik standalone HTML', () {
      const service = CaptivePortalService();
      final template = CaptivePortalTemplate.defaultTemplate();
      final html = service.generateHtml(
        template,
        vendor: CaptivePortalVendor.mikrotik,
      );

      expect(html, contains('\$(link-login-only)'));
      expect(html, contains('WireSpot Hotspot'));
      expect(html, contains('Voucher Code'));
    });

    test('generates OpenWrt standalone HTML', () {
      const service = CaptivePortalService();
      final template = CaptivePortalTemplate.defaultTemplate();
      final html = service.generateHtml(
        template,
        vendor: CaptivePortalVendor.openwrt,
      );

      expect(html, contains('\$authtarget'));
      expect(html, contains('name="tok"'));
    });
  });

  group('TelemetryAnalyticsService', () {
    test('calculates peak hours and ARPU correctly', () {
      const service = TelemetryAnalyticsService();
      final summary = RevenueSummary(
        sales: [
          SaleEntity(
            id: 'sale-1',
            routerId: 'router-1',
            amountMinor: 500,
            currency: 'USD',
            soldAt: DateTime(2026, 1, 1, 14, 30),
          ),
          SaleEntity(
            id: 'sale-2',
            routerId: 'router-1',
            amountMinor: 500,
            currency: 'USD',
            soldAt: DateTime(2026, 1, 1, 14, 45),
          ),
        ],
        totalMinor: 1000,
        currency: 'USD',
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 1, 2),
      );

      final analytics = service.analyze(summary: summary, vouchers: []);

      expect(analytics.peakHourLabel, contains('14:00 - 15:00'));
      expect(analytics.arpuMajor, 10.0);
    });
  });

  group('OperatorPermissionMatrix', () {
    test('enforces RBAC permissions', () {
      expect(
        OperatorPermissionMatrix.canManageCloudBackup(OperatorRole.owner),
        isTrue,
      );
      expect(
        OperatorPermissionMatrix.canManageCloudBackup(OperatorRole.cashier),
        isFalse,
      );
      expect(
        OperatorPermissionMatrix.canManageRouters(OperatorRole.manager),
        isTrue,
      );
      expect(
        OperatorPermissionMatrix.canManageRouters(OperatorRole.cashier),
        isFalse,
      );
      expect(
        OperatorPermissionMatrix.canSellVouchers(OperatorRole.cashier),
        isTrue,
      );
    });
  });

  group('VoucherPrintService', () {
    test('generates ESC/POS thermal command bytes', () {
      const service = VoucherPrintService();
      final voucher = VoucherEntity(
        id: 'v-1',
        routerId: 'router-1',
        username: 'WS-8A2F',
        priceMinor: 250,
        currency: 'USD',
        profileId: '1Hour-5MBPS',
        generatedAt: DateTime.now(),
      );
      final config = TicketLayoutConfig.defaultConfig();

      final bytes = service.generateEscPosBytes(
        voucher,
        config,
        businessName: 'Test Cafe',
      );

      expect(bytes, isNotEmpty);
      expect(bytes, containsAll([0x1B, 0x40])); // ESC @ init
    });
  });

  group('NetworkSecurityService', () {
    test('detects bandwidth hogs exceeding threshold', () {
      const service = NetworkSecurityService();
      final reports = service.detectBandwidthHogs([
        const HotspotActiveSessionEntity(
          id: 'sess-1',
          user: 'user_1',
          bytesIn: 600 * 1024 * 1024,
          bytesOut: 100 * 1024 * 1024,
        ),
        const HotspotActiveSessionEntity(
          id: 'sess-2',
          user: 'user_2',
          bytesIn: 10 * 1024 * 1024,
          bytesOut: 5 * 1024 * 1024,
        ),
      ], thresholdMb: 500.0);

      expect(reports.length, 1);
      expect(reports.first.session.id, 'sess-1');
    });
  });
}
