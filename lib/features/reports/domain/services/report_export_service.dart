import '../../../../core/branding/app_branding.dart';
import '../entities/report_export.dart';
import '../entities/revenue_summary.dart';

class ReportExportService {
  const ReportExportService();

  ReportExport export(ReportExportRequest request) {
    final extension = switch (request.format) {
      ReportExportFormat.pdf => 'pdf.txt',
      ReportExportFormat.excel => 'csv',
    };
    return ReportExport(
      format: request.format,
      fileName: 'wirespot-report-${DateTime.now().millisecondsSinceEpoch}.$extension',
      content: switch (request.format) {
        ReportExportFormat.pdf => _pdfText(request.summary),
        ReportExportFormat.excel => _csv(request.summary),
      },
    );
  }

  String _pdfText(RevenueSummary summary) {
    return [
      AppBranding.companyName,
      'WireSpot Revenue Report',
      'From: ${summary.from.toIso8601String()}',
      'To: ${summary.to.toIso8601String()}',
      'Transactions: ${summary.transactionCount}',
      'Total: ${summary.currency} ${summary.totalMajor.toStringAsFixed(0)}',
      '',
      for (final sale in summary.sales)
        '${sale.soldAt.toIso8601String()} | ${sale.currency} ${(sale.amountMinor / 100).toStringAsFixed(0)} | ${sale.note ?? ''}',
    ].join('\n');
  }

  String _csv(RevenueSummary summary) {
    return [
      'sold_at,router_id,voucher_id,amount,currency,payment_method,note',
      for (final sale in summary.sales)
        [
          sale.soldAt.toIso8601String(),
          sale.routerId,
          sale.voucherId ?? '',
          (sale.amountMinor / 100).toStringAsFixed(0),
          sale.currency,
          sale.paymentMethod ?? '',
          _escapeCsv(sale.note ?? ''),
        ].join(','),
    ].join('\n');
  }

  String _escapeCsv(String value) {
    if (!value.contains(',') && !value.contains('"') && !value.contains('\n')) {
      return value;
    }
    return '"${value.replaceAll('"', '""')}"';
  }
}
