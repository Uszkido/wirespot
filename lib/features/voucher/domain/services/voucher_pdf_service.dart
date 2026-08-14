import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../entities/voucher_receipt.dart';

class VoucherPdfService {
  const VoucherPdfService();

  Future<Uint8List> buildPdf(VoucherReceipt receipt) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return _buildVoucherCard(receipt);
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> buildPdfBatch(List<VoucherReceipt> receipts) async {
    final pdf = pw.Document();

    for (final receipt in receipts) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return _buildVoucherCard(receipt);
          },
        ),
      );
    }

    return pdf.save();
  }

  pw.Widget _buildVoucherCard(VoucherReceipt receipt) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
      ),
      padding: const pw.EdgeInsets.all(24),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            receipt.businessName.isEmpty ? 'Wi-Fi Voucher' : receipt.businessName,
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 16),
          if (receipt.showQrCode) ...[
            pw.Container(
              height: 150,
              width: 150,
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: receipt.qrPayload.isNotEmpty ? receipt.qrPayload : receipt.voucher.username,
                drawText: false,
              ),
            ),
            pw.SizedBox(height: 24),
          ],
          
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              children: [
                _buildRow('Username', receipt.voucher.username),
                if (receipt.voucher.password != null && receipt.voucher.password!.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  _buildRow('Password', receipt.voucher.password!),
                ],
              ],
            ),
          ),
          
          pw.SizedBox(height: 24),
          
          if (receipt.voucher.validityMinutes != null) ...[
            _buildInfoRow('Validity', '${receipt.voucher.validityMinutes} Minutes'),
            pw.SizedBox(height: 4),
          ],
          if (receipt.voucher.priceMinor > 0) ...[
            _buildInfoRow('Price', '${receipt.voucher.currency} ${(receipt.voucher.priceMinor / 100).toStringAsFixed(0)}'),
            pw.SizedBox(height: 4),
          ],
          
          pw.Spacer(),
          pw.Text(
            'Powered by WireSpot',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey600,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          '$label: ',
          style: const pw.TextStyle(
            fontSize: 14,
            color: PdfColors.grey600,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
