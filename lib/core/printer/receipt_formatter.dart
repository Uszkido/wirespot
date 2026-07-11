import '../../features/voucher/domain/entities/voucher_receipt.dart';
import 'printer_models.dart';

class ReceiptFormatter {
  const ReceiptFormatter._();

  static String formatVoucher(
    VoucherReceipt receipt, {
    PrinterPaperWidth paperWidth = PrinterPaperWidth.mm58,
  }) {
    final width = paperWidth == PrinterPaperWidth.mm80 ? 48 : 32;
    final divider = ''.padLeft(width, '-');
    final lines = receipt.toPlainText().split('\n');

    return [
      _center(lines.first, width),
      divider,
      ...lines.skip(1),
      divider,
      _center('Powered by WireSpot', width),
      '',
      '',
    ].join('\n');
  }

  static String _center(String value, int width) {
    if (value.length >= width) {
      return value;
    }
    final left = ((width - value.length) / 2).floor();
    return '${''.padLeft(left)}$value';
  }
}
