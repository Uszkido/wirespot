import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/reports/domain/entities/report_export.dart';
import '../../features/voucher/domain/entities/voucher_receipt.dart';
import 'share_service.dart';

class PlatformShareService implements ShareService {
  const PlatformShareService({
    MethodChannel channel = const MethodChannel(_channelName),
  }) : _channel = channel;

  static const _channelName = 'com.wirespot.app/share';

  final MethodChannel _channel;

  @override
  Future<void> shareVoucherReceipt(VoucherReceipt receipt) {
    return _shareText(
      subject: 'WireSpot voucher ${receipt.voucher.username}',
      text: receipt.toPlainText(),
    );
  }

  @override
  Future<void> shareVoucherReceipts(List<VoucherReceipt> receipts) {
    if (receipts.isEmpty) {
      return Future.value();
    }
    return _shareText(
      subject: 'WireSpot vouchers (${receipts.length})',
      text: receipts
          .map((receipt) => receipt.toPlainText())
          .join('\n\n---\n\n'),
    );
  }

  @override
  Future<void> shareReportExport(ReportExport export) {
    final mimeType = switch (export.format) {
      ReportExportFormat.pdf => 'application/pdf',
      ReportExportFormat.excel =>
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    };
    return Share.shareXFiles(
      [XFile.fromData(export.bytes, mimeType: mimeType, name: export.fileName)],
      subject: export.fileName,
      text: 'WireSpot export',
    );
  }

  Future<void> _shareText({required String subject, required String text}) {
    return _channel.invokeMethod<void>('shareText', {
      'subject': subject,
      'text': text,
    });
  }
}
