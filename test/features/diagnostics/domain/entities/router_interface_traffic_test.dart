import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/diagnostics/domain/entities/router_interface_traffic.dart';

void main() {
  group('RouterInterfaceTraffic', () {
    test('calculates Kbps and Mbps formatting correctly', () {
      final traffic = RouterInterfaceTraffic(
        interfaceName: 'ether1',
        rxBytesPerSec: 125000, // 1 Mbps
        txBytesPerSec: 25000, // 200 Kbps
        timestamp: DateTime.now(),
      );

      expect(traffic.rxMbps, closeTo(1.0, 0.01));
      expect(traffic.txKbps, closeTo(200.0, 0.1));
      expect(traffic.rxFormatted, contains('1.00 Mbps'));
      expect(traffic.txFormatted, contains('200.0 Kbps'));
    });
  });
}
