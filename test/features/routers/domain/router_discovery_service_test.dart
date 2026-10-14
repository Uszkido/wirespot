import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/routers/domain/services/router_discovery_service.dart';

void main() {
  test('parses RouterOS MNDP identity, address, and metadata', () {
    final packet = <int>[
      ...'MNDP'.codeUnits,
      ..._field(0x0001, 'AA:BB:CC:DD:EE:FF'.codeUnits),
      ..._field(0x0002, 'MikroTik-Gateway'.codeUnits),
      ..._field(0x0003, '7.16.2'.codeUnits),
      ..._field(0x0007, 'RB5009'.codeUnits),
      ..._field(0x0009, [192, 168, 88, 1]),
    ];

    final result = RouterDiscoveryService.parseMndp(Uint8List.fromList(packet));

    expect(result?.host, '192.168.88.1');
    expect(result?.displayName, 'MikroTik-Gateway');
    expect(result?.macAddress, 'AA:BB:CC:DD:EE:FF');
    expect(result?.version, '7.16.2');
    expect(result?.boardName, 'RB5009');
  });

  test('ignores malformed and unrelated packets', () {
    expect(
      RouterDiscoveryService.parseMndp(Uint8List.fromList('hello'.codeUnits)),
      isNull,
    );
    expect(
      RouterDiscoveryService.parseMndp(
        Uint8List.fromList([...'MNDP'.codeUnits, 0, 1, 0, 10, 1]),
      ),
      isNull,
    );
  });
}

List<int> _field(int type, List<int> value) => [
  type >> 8,
  type & 0xff,
  value.length >> 8,
  value.length & 0xff,
  ...value,
];
