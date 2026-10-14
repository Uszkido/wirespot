import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../entities/router_discovery_result.dart';

/// Discovers MikroTik devices advertising RouterOS MNDP on the local LAN.
class RouterDiscoveryService {
  const RouterDiscoveryService();

  static const discoveryPort = 5678;

  Future<List<RouterDiscoveryResult>> discover({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    try {
      socket.broadcastEnabled = true;
      final found = <String, RouterDiscoveryResult>{};
      final done = Completer<void>();
      final subscription = socket.listen((event) {
        if (event != RawSocketEvent.read) return;
        final datagram = socket.receive();
        if (datagram == null) return;
        final result = parseMndp(datagram.data);
        if (result != null) found[result.host] = result;
      });
      socket.send(
        Uint8List.fromList(const [0x4d, 0x4e, 0x44, 0x50]),
        InternetAddress('255.255.255.255'),
        discoveryPort,
      );
      Timer(timeout, () {
        if (!done.isCompleted) done.complete();
      });
      await done.future;
      await subscription.cancel();
      return found.values.toList()
        ..sort((a, b) => a.displayName.compareTo(b.displayName));
    } finally {
      socket.close();
    }
  }

  /// Parses one RouterOS MNDP packet. Returns null for unrelated packets.
  static RouterDiscoveryResult? parseMndp(Uint8List bytes) {
    if (bytes.length < 4 ||
        String.fromCharCodes(bytes.sublist(0, 4)) != 'MNDP') {
      return null;
    }
    var offset = 4;
    String? identity;
    String? mac;
    String? version;
    String? board;
    String? interfaceName;
    String? host;
    while (offset + 4 <= bytes.length) {
      final type = (bytes[offset] << 8) | bytes[offset + 1];
      final length = (bytes[offset + 2] << 8) | bytes[offset + 3];
      offset += 4;
      if (length > bytes.length - offset) break;
      final value = bytes.sublist(offset, offset + length);
      offset += length;
      switch (type) {
        case 0x0001:
          mac = _text(value);
        case 0x0002:
          identity = _text(value);
        case 0x0003:
          version = _text(value);
        case 0x0007:
          board = _text(value);
        case 0x0009:
          if (value.length == 4) host = value.join('.');
        case 0x000b:
          interfaceName = _text(value);
      }
    }
    final discoveredHost = host;
    if (discoveredHost == null || discoveredHost.isEmpty) return null;
    return RouterDiscoveryResult(
      host: discoveredHost,
      identity: identity,
      macAddress: mac,
      version: version,
      boardName: board,
      interfaceName: interfaceName,
    );
  }

  static String _text(List<int> value) {
    return utf8
        .decode(value, allowMalformed: true)
        .replaceAll('\u0000', '')
        .trim();
  }
}
