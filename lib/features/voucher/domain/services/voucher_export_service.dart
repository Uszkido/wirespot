import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../reports/domain/entities/report_export.dart';
import '../entities/voucher_entity.dart';

class VoucherExportService {
  const VoucherExportService();

  Future<ReportExport> export(
    List<VoucherEntity> vouchers,
    ReportExportFormat format,
  ) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final content = _csv(vouchers);
    final bytes = format == ReportExportFormat.pdf
        ? await _pdf(vouchers)
        : _excel(vouchers);
    return ReportExport(
      format: format,
      fileName:
          'wirespot-vouchers-$stamp.${format == ReportExportFormat.pdf ? 'pdf' : 'xlsx'}',
      content: content,
      bytes: bytes,
    );
  }

  Future<Uint8List> _pdf(List<VoucherEntity> vouchers) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text('WireSpot Voucher Sheet', style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 12),
          for (final voucher in vouchers)
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Text(
                'Username: ${voucher.username}\nPassword: ${voucher.password ?? '—'}\nValidity: ${voucher.validityMinutes ?? 'Unlimited'} minutes\nPrice: ${voucher.currency} ${(voucher.priceMinor / 100).toStringAsFixed(0)}',
              ),
            ),
        ],
      ),
    );
    return document.save();
  }

  Uint8List _excel(List<VoucherEntity> vouchers) {
    final workbook = Excel.createExcel();
    final sheet = workbook['Vouchers'];
    sheet.appendRow([
      TextCellValue('Username'),
      TextCellValue('Password'),
      TextCellValue('Validity minutes'),
      TextCellValue('Price minor'),
      TextCellValue('Currency'),
      TextCellValue('Generated at'),
    ]);
    for (final voucher in vouchers) {
      sheet.appendRow([
        TextCellValue(voucher.username),
        TextCellValue(voucher.password ?? ''),
        IntCellValue(voucher.validityMinutes ?? 0),
        IntCellValue(voucher.priceMinor),
        TextCellValue(voucher.currency),
        TextCellValue(voucher.generatedAt.toIso8601String()),
      ]);
    }
    return Uint8List.fromList(workbook.encode()!);
  }

  String _csv(List<VoucherEntity> vouchers) => [
    'username,password,validity_minutes,price_minor,currency,generated_at',
    for (final voucher in vouchers)
      '${voucher.username},${voucher.password ?? ''},${voucher.validityMinutes ?? ''},${voucher.priceMinor},${voucher.currency},${voucher.generatedAt.toIso8601String()}',
  ].join('\n');
}
