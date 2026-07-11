import '../../features/voucher/domain/entities/voucher_receipt.dart';

abstract interface class ShareService {
  Future<void> shareVoucherReceipt(VoucherReceipt receipt);
}
