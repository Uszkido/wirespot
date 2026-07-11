enum PrinterPaperWidth {
  mm58,
  mm80,
}

class BluetoothPrinterDevice {
  const BluetoothPrinterDevice({
    required this.name,
    required this.address,
  });

  final String name;
  final String address;
}

class PrintJobResult {
  const PrintJobResult({
    required this.success,
    this.message,
  });

  final bool success;
  final String? message;
}
