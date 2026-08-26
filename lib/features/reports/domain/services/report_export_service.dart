import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
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
          ? await _buildPdf(request.summary, settings)
          : _buildExcel(request.summary),
    );
  }

  Future<Uint8List> _buildPdf(
    RevenueSummary summary,
    AppSettingsSnapshot? settings,
  ) async {
    final document = pw.Document();
    final businessName = settings?.businessName ?? AppBranding.companyName;
    final supportEmail = settings?.businessEmail ?? AppBranding.supportEmail;
    final supportPhone = settings?.businessPhone ?? AppBranding.supportPhone;
    final website = settings?.businessWebsite ?? AppBranding.website;

    document.addPage(
      pw.MultiPage(
        header: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 12),
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.blueGrey800, width: 2),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    businessName,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey900,
                    ),
                  ),
                  pw.Text(
                    'WireSpot Hotspot Revenue Report',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.blueGrey600,
                    ),
                  ),
                ],
              ),
              pw.Text(
                AppBranding.appName,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 12),
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey300, width: 1),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '$supportEmail • $supportPhone • $website',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Text(
                      'PERIOD',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '${_dateTime(summary.from)} - ${_dateTime(summary.to)}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text(
                      'TRANSACTIONS',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '${summary.transactionCount}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text(
                      'TOTAL REVENUE',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '${summary.currency} ${summary.totalMajor.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Sales Breakdown',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
          pw.SizedBox(height: 8),
          if (summary.sales.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 20),
              child: pw.Center(
                child: pw.Text(
                  'No sales recorded for this period.',
                  style: pw.TextStyle(color: PdfColors.grey600),
                ),
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: [
                'Date & Time',
                'Router',
                'Voucher',
                'Payment',
                'Amount',
              ],
              data: [
                for (final sale in summary.sales)
                  [
                    _dateTime(sale.soldAt),
                    sale.routerId,
                    sale.voucherId ?? '-',
                    sale.paymentMethod ?? 'Cash',
                    '${sale.currency} ${(sale.amountMinor / 100).toStringAsFixed(2)}',
                  ],
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 10,
              ),
              headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
              rowDecoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                ),
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
            ),
        ],
      ),
    );
    return document.save();
  }

  Uint8List _buildExcel(RevenueSummary summary) {
    final workbook = Excel.createExcel();
    final sheet = workbook['Revenue report'];
    sheet.appendRow([
      TextCellValue('Sold at'),
      TextCellValue('Router ID'),
      TextCellValue('Voucher ID'),
      TextCellValue('Payment Method'),
      TextCellValue('Amount (Minor)'),
      TextCellValue('Amount (Major)'),
      TextCellValue('Currency'),
      TextCellValue('Notes'),
    ]);
    for (final sale in summary.sales) {
      sheet.appendRow([
        TextCellValue(sale.soldAt.toIso8601String()),
        TextCellValue(sale.routerId),
        TextCellValue(sale.voucherId ?? ''),
        TextCellValue(sale.paymentMethod ?? 'Cash'),
        IntCellValue(sale.amountMinor),
        DoubleCellValue(sale.amountMinor / 100),
        TextCellValue(sale.currency),
        TextCellValue(sale.note ?? ''),
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
