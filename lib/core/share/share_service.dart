import '../../features/reports/domain/entities/report_export.dart';
import '../../features/voucher/domain/entities/voucher_receipt.dart';

abstract interface class ShareService {
  Future<void> shareVoucherReceipt(VoucherReceipt receipt);

  Future<void> shareReportExport(ReportExport export);
}
