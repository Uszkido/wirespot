import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/reports/domain/entities/report_export.dart';
import 'package:wirespot/features/reports/domain/entities/revenue_summary.dart';
import 'package:wirespot/features/reports/domain/entities/sale_entity.dart';
import 'package:wirespot/features/reports/domain/services/report_export_service.dart';

void main() {
  test('exports branded CSV content', () {
    const service = ReportExportService();
    final summary = RevenueSummary(
      sales: [
        SaleEntity(
          id: 'sale-1',
          routerId: 'router-1',
          amountMinor: 50000,
          currency: 'NGN',
          soldAt: DateTime(2026),
          note: 'Voucher sale',
        ),
      ],
      totalMinor: 50000,
      currency: 'NGN',
      from: DateTime(2026),
      to: DateTime(2026, 1, 2),
    );

    final export = service.export(
      ReportExportRequest(summary: summary, format: ReportExportFormat.excel),
    );

    expect(export.fileName, endsWith('.csv'));
    expect(export.content, contains('sold_at,router_id'));
    expect(export.content, contains('amount_minor,amount'));
    expect(export.content, contains('Voucher sale'));
  });

  test('exports polished PDF text content', () {
    const service = ReportExportService();
    final summary = RevenueSummary(
      sales: [
        SaleEntity(
          id: 'sale-1',
          routerId: 'router-1',
          voucherId: 'voucher-1',
          amountMinor: 50000,
          currency: 'NGN',
          soldAt: DateTime(2026, 1, 1, 10),
          paymentMethod: 'cash',
          note: 'Voucher sale',
        ),
      ],
      totalMinor: 50000,
      currency: 'NGN',
      from: DateTime(2026),
      to: DateTime(2026, 1, 2),
    );

    final export = service.export(
      ReportExportRequest(summary: summary, format: ReportExportFormat.pdf),
    );

    expect(export.fileName, endsWith('.pdf.txt'));
    expect(export.content, contains('WireSpot Revenue Report'));
    expect(export.content, contains('Summary'));
    expect(export.content, contains('Router: router-1'));
    expect(export.content, contains('Payment: cash'));
  });
}
