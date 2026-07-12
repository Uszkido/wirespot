import 'package:flutter/services.dart';

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
    return _channel.invokeMethod<void>('shareText', {
      'subject': 'WireSpot voucher ${receipt.voucher.username}',
      'text': receipt.toPlainText(),
    });
  }
}
