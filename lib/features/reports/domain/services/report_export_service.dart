import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/branding/app_branding.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../entities/report_export.dart';
import '../entities/revenue_summary.dart';

class ReportExportService {
  const ReportExportService();

  Future<ReportExport> export(
    ReportExportRequest request, {
    AppSettingsSnapshot? settings,
  }) async {
    final extension = switch (request.format) {
      ReportExportFormat.pdf => 'pdf',
      ReportExportFormat.excel => 'xlsx',
    };
    final content = request.format == ReportExportFormat.pdf
        ? _pdfText(request.summary, settings)
        : _csv(request.summary);
    return ReportExport(
      format: request.format,
      fileName:
          'wirespot-report-${DateTime.now().millisecondsSinceEpoch}.$extension',
      content: content,
      bytes: request.format == ReportExportFormat.pdf
          ? await _buildPdf(content)
          : _buildExcel(request.summary),
    );
  }

  Future<Uint8List> _buildPdf(String content) async {
    final document = pw.Document();
    document.addPage(pw.MultiPage(build: (_) => [pw.Text(content)]));
    return document.save();
  }

  Uint8List _buildExcel(RevenueSummary summary) {
    final workbook = Excel.createExcel();
    final sheet = workbook['Revenue report'];
    sheet.appendRow([
      TextCellValue('Sold at'),
      TextCellValue('Router'),
      TextCellValue('Voucher'),
      TextCellValue('Amount'),
      TextCellValue('Currency'),
    ]);
    for (final sale in summary.sales) {
      sheet.appendRow([
        TextCellValue(sale.soldAt.toIso8601String()),
        TextCellValue(sale.routerId),
        TextCellValue(sale.voucherId ?? ''),
        IntCellValue(sale.amountMinor),
        TextCellValue(sale.currency),
      ]);
    }
    return Uint8List.fromList(workbook.encode()!);
  }

  String _pdfText(RevenueSummary summary, AppSettingsSnapshot? settings) {
    final divider = ''.padLeft(48, '=');
    final businessName = settings?.businessName ?? AppBranding.companyName;
    final supportEmail = settings?.businessEmail ?? AppBranding.supportEmail;
    final supportPhone = settings?.businessPhone ?? AppBranding.supportPhone;
    final website = settings?.businessWebsite ?? AppBranding.website;
    return [
      divider,
      businessName,
      'WireSpot Revenue Report',
      AppBranding.poweredByLine,
      divider,
      'Period',
      'From: ${_dateTime(summary.from)}',
      'To:   ${_dateTime(summary.to)}',
      '',
      'Summary',
      'Transactions: ${summary.transactionCount}',
      'Total: ${summary.currency} ${summary.totalMajor.toStringAsFixed(0)}',
      divider,
      'Sales',
      if (summary.sales.isEmpty) 'No sales recorded in this period.',
      for (final sale in summary.sales) ...[
        _dateTime(sale.soldAt),
        'Router: ${sale.routerId}',
        if (sale.voucherId != null) 'Voucher: ${sale.voucherId}',
        'Amount: ${sale.currency} ${(sale.amountMinor / 100).toStringAsFixed(0)}',
        if (sale.paymentMethod != null) 'Payment: ${sale.paymentMethod}',
        if (sale.note != null && sale.note!.isNotEmpty) 'Note: ${sale.note}',
        ''.padLeft(48, '-'),
      ],
      '',
      supportEmail,
      supportPhone,
      website,
    ].join('\n');
  }

  String _csv(RevenueSummary summary) {
    return [
      'sold_at,router_id,voucher_id,amount_minor,amount,currency,payment_method,note',
      for (final sale in summary.sales)
        [
          _escapeCsv(sale.soldAt.toIso8601String()),
          _escapeCsv(sale.routerId),
          _escapeCsv(sale.voucherId ?? ''),
          sale.amountMinor.toString(),
          (sale.amountMinor / 100).toStringAsFixed(0),
          _escapeCsv(sale.currency),
          _escapeCsv(sale.paymentMethod ?? ''),
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

  String _dateTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}
