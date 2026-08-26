import '../../features/reports/domain/entities/report_export.dart';
import '../../features/voucher/domain/entities/voucher_receipt.dart';

abstract interface class ShareService {
  Future<void> shareVoucherReceipt(VoucherReceipt receipt);

  Future<void> shareVoucherReceipts(List<VoucherReceipt> receipts);

  Future<void> shareReportExport(ReportExport export);

  Future<void> sharePdfCard(
    List<int> bytes,
    String fileName, {
    String? subject,
  });

  Future<void> shareFile({
    required String path,
    String? mimeType,
    String? subject,
  });
}
