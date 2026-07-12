import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class WireGuardQrScanPage extends StatefulWidget {
  const WireGuardQrScanPage({super.key});

  @override
  State<WireGuardQrScanPage> createState() => _WireGuardQrScanPageState();
}

class _WireGuardQrScanPageState extends State<WireGuardQrScanPage> {
  bool _handledScan = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan WireGuard QR')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(onDetect: _handleDetect),
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surface.withAlpha(230),
                child: Text(
                  'Place the WireGuard configuration QR inside the frame.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_handledScan) {
      return;
    }
    final rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstWhere((value) => value.trim().isNotEmpty, orElse: () => '');
    if (rawValue.isEmpty || !mounted) {
      return;
    }
    _handledScan = true;
    Navigator.of(context).pop(rawValue);
  }
}
