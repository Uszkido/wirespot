import '../entities/ticket_layout_config.dart';
import '../entities/voucher_entity.dart';

class VoucherThermalTicketService {
  const VoucherThermalTicketService();

  String formatTicketText({
    required VoucherEntity voucher,
    required TicketLayoutConfig config,
  }) {
    final width = config.maxCharWidth;
    final divider = '=' * width;
    final dashDivider = '-' * width;

    final priceStr = (voucher.priceMinor / 100).toStringAsFixed(2);
    final validityStr = voucher.validityMinutes != null
        ? '${voucher.validityMinutes} mins'
        : (voucher.profileId ?? 'Standard Plan');

    final buffer = StringBuffer()
      ..writeln(_center(config.businessName.toUpperCase(), width))
      ..writeln(_center(config.headline, width))
      ..writeln(divider)
      ..writeln(_twoColumn('VOUCHER CODE:', voucher.username, width));

    if (voucher.password != null && voucher.password!.isNotEmpty) {
      buffer.writeln(_twoColumn('PASSWORD:', voucher.password!, width));
    }

    buffer.writeln(_twoColumn('PLAN:', validityStr, width));

    if (config.showPrice) {
      buffer.writeln(
        _twoColumn('PRICE:', '${config.currencySymbol}$priceStr', width),
      );
    }

    buffer
      ..writeln(dashDivider)
      ..writeln(_center(config.footerNote, width))
      ..writeln(divider)
      ..writeln();

    return buffer.toString();
  }

  String formatBatchTicketText({
    required List<VoucherEntity> vouchers,
    required TicketLayoutConfig config,
  }) {
    final buffer = StringBuffer();
    for (int i = 0; i < vouchers.length; i++) {
      buffer.writeln(formatTicketText(voucher: vouchers[i], config: config));
      if (i < vouchers.length - 1) {
        buffer.writeln('\n------------------------------\n');
      }
    }
    return buffer.toString();
  }

  String _center(String text, int width) {
    if (text.length >= width) {
      return text.substring(0, width);
    }
    final leftPadding = (width - text.length) ~/ 2;
    final rightPadding = width - text.length - leftPadding;
    return ' ' * leftPadding + text + ' ' * rightPadding;
  }

  String _twoColumn(String left, String right, int width) {
    final available = width - left.length;
    if (right.length >= available) {
      return '$left ${right.substring(0, available - 1)}';
    }
    final padding = width - left.length - right.length;
    return left + ' ' * padding + right;
  }
}
