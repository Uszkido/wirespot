import 'dart:typed_data';

import '../entities/ticket_layout_config.dart';
import '../entities/voucher_entity.dart';

class VoucherPrintService {
  const VoucherPrintService();

  Uint8List generateEscPosBytes(
    VoucherEntity voucher,
    TicketLayoutConfig config, {
    required String businessName,
  }) {
    final bytes = <int>[];

    // Initialize ESC/POS Printer
    bytes.addAll([0x1B, 0x40]);

    // Center alignment
    bytes.addAll([0x1B, 0x61, 0x01]);

    // Header: Business Name (Double height/width)
    bytes.addAll([0x1D, 0x21, 0x11]);
    bytes.addAll(businessName.codeUnits);
    bytes.addAll([0x0A]);

    // Reset font size
    bytes.addAll([0x1D, 0x21, 0x00]);
    if (config.headerSlogan.isNotEmpty) {
      bytes.addAll(config.headerSlogan.codeUnits);
      bytes.addAll([0x0A]);
    }
    bytes.addAll('--------------------------------'.codeUnits);
    bytes.addAll([0x0A]);

    // Voucher Code (Double size bold)
    bytes.addAll([0x1B, 0x45, 0x01]);
    bytes.addAll([0x1D, 0x21, 0x11]);
    bytes.addAll('VOUCHER: ${voucher.username}'.codeUnits);
    bytes.addAll([0x0A]);

    // Reset bold/font
    bytes.addAll([0x1B, 0x45, 0x00]);
    bytes.addAll([0x1D, 0x21, 0x00]);
    bytes.addAll('Profile: ${voucher.profileId}'.codeUnits);
    bytes.addAll([0x0A]);

    if (voucher.validityMinutes != null) {
      bytes.addAll('Validity: ${voucher.validityMinutes} minutes'.codeUnits);
      bytes.addAll([0x0A]);
    }

    bytes.addAll('--------------------------------'.codeUnits);
    bytes.addAll([0x0A]);

    if (config.footerText.isNotEmpty) {
      bytes.addAll(config.footerText.codeUnits);
      bytes.addAll([0x0A]);
    }

    bytes.addAll('Powered by WireSpot'.codeUnits);
    bytes.addAll([0x0A, 0x0A, 0x0A, 0x0A]);

    // Paper Cut Command
    bytes.addAll([0x1D, 0x56, 0x00]);

    return Uint8List.fromList(bytes);
  }
}
