import '../../features/voucher/domain/entities/voucher_receipt.dart';
import 'printer_models.dart';

class ReceiptFormatter {
  const ReceiptFormatter._();

  static const _esc = '\x1B';
  static const _gs = '\x1D';
  static const _alignLeft = '$_esc\x61\x00';
  static const _alignCenter = '$_esc\x61\x01';
  static const _boldOn = '$_esc\x45\x01';
  static const _boldOff = '$_esc\x45\x00';
  static const _doubleOn = '$_gs\x21\x11';
  static const _doubleOff = '$_gs\x21\x00';
  static const _qrModel2 = '$_gs(k\x04\x001A2\x00';
  static const _qrErrorCorrectionM = '$_gs(k\x03\x001E1';
  static const _qrPrint = '$_gs(k\x03\x001Q0';

  static String formatVoucher(
    VoucherReceipt receipt, {
    PrinterPaperWidth paperWidth = PrinterPaperWidth.mm58,
  }) {
    final width = paperWidth == PrinterPaperWidth.mm80 ? 48 : 32;
    final divider = ''.padLeft(width, '-');
    final voucher = receipt.voucher;
    final price =
        '${voucher.currency} ${(voucher.priceMinor / 100).toStringAsFixed(0)}';
    final validity = voucher.validityMinutes == null
        ? 'Unlimited'
        : _formatValidity(voucher.validityMinutes!);

    return [
      _alignCenter,
      if (receipt.showLogo) ...[
        _boldOn,
        _center('WIRESPOT', width),
        _boldOff,
      ],
      _doubleOn,
      _center(receipt.businessName, width),
      _doubleOff,
      _center('HOTSPOT VOUCHER', width),
      _alignLeft,
      divider,
      _row('Template', receipt.templateName, width),
      _row('Username', voucher.username, width),
      if (voucher.password != null) _row('Password', voucher.password!, width),
      _row('Validity', validity, width),
      if (receipt.showPrice) _row('Price', price, width),
      _row('Generated', _formatDate(voucher.generatedAt), width),
      if (voucher.note != null && voucher.note!.trim().isNotEmpty) ...[
        divider,
        ..._wrap('Note: ${voucher.note!.trim()}', width),
      ],
      if (receipt.showQrCode) ...[
        divider,
        _alignCenter,
        _boldOn,
        _center('SCAN / LOGIN', width),
        _boldOff,
        _nativeQr(receipt.qrPayload, paperWidth),
        _alignLeft,
        ..._wrap('QR: ${receipt.qrPayload}', width),
      ],
      divider,
      _alignCenter,
      ..._wrapCentered(receipt.supportPhone, width),
      ..._wrapCentered(receipt.website, width),
      ..._wrapCentered(receipt.footer, width),
      _boldOn,
      _center('Powered by WireSpot', width),
      _boldOff,
      _alignLeft,
      '',
      '',
    ].join('\n');
  }

  static String _nativeQr(String payload, PrinterPaperWidth paperWidth) {
    final data = payload.trim();
    if (data.isEmpty) {
      return '';
    }
    final size = paperWidth == PrinterPaperWidth.mm80 ? 8 : 6;
    final bytesLength = data.length + 3;
    final pL = String.fromCharCode(bytesLength % 256);
    final pH = String.fromCharCode(bytesLength ~/ 256);
    return [
      _qrModel2,
      '$_gs(k\x03\x001C${String.fromCharCode(size)}',
      _qrErrorCorrectionM,
      '$_gs(k$pL${pH}1P0$data',
      _qrPrint,
    ].join();
  }

  static String _row(String label, String value, int width) {
    final prefix = '$label: ';
    final available = width - prefix.length;
    if (available > 8 && value.length <= available) {
      return '$prefix${value.padLeft(available)}';
    }
    return [
      prefix.trimRight(),
      ..._wrap(value, width).map((line) => '  $line'),
    ].join('\n');
  }

  static List<String> _wrap(String value, int width) {
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return const [];
    }
    final words = normalized.split(' ');
    final lines = <String>[];
    var current = '';
    for (final word in words) {
      if (word.length > width) {
        if (current.isNotEmpty) {
          lines.add(current);
          current = '';
        }
        for (var index = 0; index < word.length; index += width) {
          final end = index + width > word.length ? word.length : index + width;
          lines.add(word.substring(index, end));
        }
        continue;
      }
      final next = current.isEmpty ? word : '$current $word';
      if (next.length > width) {
        lines.add(current);
        current = word;
      } else {
        current = next;
      }
    }
    if (current.isNotEmpty) {
      lines.add(current);
    }
    return lines;
  }

  static List<String> _wrapCentered(String value, int width) {
    return _wrap(value, width).map((line) => _center(line, width)).toList();
  }

  static String _formatValidity(int minutes) {
    if (minutes % 1440 == 0) {
      final days = minutes ~/ 1440;
      return days == 1 ? '1 day' : '$days days';
    }
    if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return hours == 1 ? '1 hour' : '$hours hours';
    }
    return '$minutes minutes';
  }

  static String _formatDate(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }

  static String _center(String value, int width) {
    if (value.length >= width) {
      return value;
    }
    final left = ((width - value.length) / 2).floor();
    return '${''.padLeft(left)}$value';
  }
}
