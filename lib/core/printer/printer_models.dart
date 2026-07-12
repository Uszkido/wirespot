enum PrinterPaperWidth { mm58, mm80 }

class BluetoothPrinterDevice {
  const BluetoothPrinterDevice({required this.name, required this.address});

  final String name;
  final String address;
}

class PrintJobResult {
  const PrintJobResult({required this.success, this.message});

  final bool success;
  final String? message;
}

class PrinterException implements Exception {
  const PrinterException(this.message);

  final String message;

  @override
  String toString() => message;
}
