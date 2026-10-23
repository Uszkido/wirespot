import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../branding/app_branding.dart';
import '../../features/voucher/domain/entities/voucher_receipt.dart';
import 'printer_models.dart';
import 'printer_service.dart';
import 'receipt_formatter.dart';

class PlatformPrinterService implements PrinterService {
  const PlatformPrinterService({
    MethodChannel channel = const MethodChannel(_channelName),
    bool? useWindowsNative,
  }) : _channel = channel,
       _useWindowsNative = useWindowsNative;

  static const _channelName = 'com.wirespot.app/printer';

  final MethodChannel _channel;
  final bool? _useWindowsNative;

  bool get _isWindows => _useWindowsNative ?? Platform.isWindows;

  @override
  Future<List<BluetoothPrinterDevice>> pairedBluetoothPrinters() async {
    if (_isWindows) {
      return _windowsPrinters();
    }
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
    if (_isWindows) {
      return _printOnWindows(printer: printer, text: text);
    }
    try {
      final result = await _channel
          .invokeMapMethod<Object?, Object?>('printText', {
            'address': printer.address,
            'text': text,
            'paperWidth': paperWidth.name,
            'logoAsset': receipt.showLogo ? AppBranding.logoAsset : '',
            'logoFile': receipt.showLogo ? receipt.logoPath : '',
          });
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

  Future<List<BluetoothPrinterDevice>> _windowsPrinters() async {
    const script = r'''
$ErrorActionPreference = 'Stop'
Get-Printer | Select-Object Name,PortName | ConvertTo-Json -Compress
''';
    try {
      final result = await Process.run('powershell.exe', [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        script,
      ]);
      if (result.exitCode != 0) {
        throw PrinterException('${result.stderr}'.trim());
      }
      final raw = '${result.stdout}'.trim();
      if (raw.isEmpty) return const [];
      final decoded = jsonDecode(raw);
      final records = decoded is List ? decoded : [decoded];
      return records
          .whereType<Map>()
          .map(
            (item) => BluetoothPrinterDevice(
              name: '${item['Name'] ?? ''}',
              address: 'windows:${item['Name'] ?? item['PortName'] ?? ''}',
            ),
          )
          .where((printer) => printer.name.trim().isNotEmpty)
          .toList();
    } on PrinterException {
      rethrow;
    } on Object catch (error) {
      throw PrinterException('Could not load Windows printers: $error');
    }
  }

  Future<PrintJobResult> _printOnWindows({
    required BluetoothPrinterDevice printer,
    required String text,
  }) async {
    final printerName = printer.address.startsWith('windows:')
        ? printer.address.substring('windows:'.length)
        : printer.name;
    final directory = await Directory.systemTemp.createTemp('wirespot-print-');
    final file = File('${directory.path}${Platform.pathSeparator}receipt.txt');
    await file.writeAsString(text);
    final escapedPath = file.path.replaceAll("'", "''");
    final escapedPrinter = printerName.replaceAll("'", "''");
    try {
      final result = await Process.run('powershell.exe', [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        "Get-Content -LiteralPath '$escapedPath' -Raw | Out-Printer -Name '$escapedPrinter'",
      ]);
      return PrintJobResult(
        success: result.exitCode == 0,
        message: result.exitCode == 0
            ? 'Sent to Windows printer.'
            : '${result.stderr}'.trim(),
      );
    } finally {
      await directory.delete(recursive: true);
    }
  }
}
