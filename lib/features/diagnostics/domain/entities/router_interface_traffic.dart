class RouterInterfaceTraffic {
  const RouterInterfaceTraffic({
    required this.interfaceName,
    required this.rxBytesPerSec,
    required this.txBytesPerSec,
    required this.timestamp,
  });

  final String interfaceName;
  final double rxBytesPerSec;
  final double txBytesPerSec;
  final DateTime timestamp;

  double get rxKbps => (rxBytesPerSec * 8) / 1000;
  double get txKbps => (txBytesPerSec * 8) / 1000;

  double get rxMbps => rxKbps / 1000;
  double get txMbps => txKbps / 1000;

  String get rxFormatted => rxMbps >= 1.0
      ? '${rxMbps.toStringAsFixed(2)} Mbps'
      : '${rxKbps.toStringAsFixed(1)} Kbps';

  String get txFormatted => txMbps >= 1.0
      ? '${txMbps.toStringAsFixed(2)} Mbps'
      : '${txKbps.toStringAsFixed(1)} Kbps';
}
