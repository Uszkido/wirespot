import 'package:flutter/services.dart';

import '../../features/voucher/domain/entities/voucher_receipt.dart';
import 'printer_models.dart';
import 'printer_service.dart';
import 'receipt_formatter.dart';

class PlatformPrinterService implements PrinterService {
  const PlatformPrinterService({
    MethodChannel channel = const MethodChannel(_channelName),
  }) : _channel = channel;

  static const _channelName = 'com.wirespot.app/printer';

  final MethodChannel _channel;

  @override
  Future<List<BluetoothPrinterDevice>> pairedBluetoothPrinters() async {
    try {
      final result = await _channel.invokeListMethod<Map<Object?, Object?>>(
        'pairedBluetoothPrinters',
      );
      return (result ?? const [])
          .map(
            (item) => BluetoothPrinterDevice(
              name: item['name'] as String? ?? '',
              address: item['address'] as String? ?? '',
            ),
          )
          .where((printer) => printer.address.isNotEmpty)
          .toList();
    } on PlatformException catch (error) {
      throw PrinterException(
        error.message ?? 'Could not load Bluetooth printers.',
      );
    }
  }

  @override
  Future<PrintJobResult> printVoucherReceipt({
    required BluetoothPrinterDevice printer,
    required VoucherReceipt receipt,
    PrinterPaperWidth paperWidth = PrinterPaperWidth.mm58,
  }) async {
    final text = ReceiptFormatter.formatVoucher(
      receipt,
      paperWidth: paperWidth,
    );
    try {
      final result = await _channel.invokeMapMethod<Object?, Object?>(
        'printText',
        {
          'address': printer.address,
          'text': text,
          'paperWidth': paperWidth.name,
          'logoAsset': receipt.showLogo ? 'assets/images/vexel_logo.png' : '',
        },
      );
      return PrintJobResult(
        success: result?['success'] as bool? ?? false,
        message: result?['message'] as String?,
      );
    } on PlatformException catch (error) {
      return PrintJobResult(
        success: false,
        message: error.message ?? 'Could not print receipt.',
      );
    }
  }
}
