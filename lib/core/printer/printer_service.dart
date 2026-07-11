import '../../features/voucher/domain/entities/voucher_receipt.dart';
import 'printer_models.dart';

abstract interface class PrinterService {
  Future<List<BluetoothPrinterDevice>> pairedBluetoothPrinters();

  Future<PrintJobResult> printVoucherReceipt({
    required BluetoothPrinterDevice printer,
    required VoucherReceipt receipt,
    PrinterPaperWidth paperWidth = PrinterPaperWidth.mm58,
  });
}
