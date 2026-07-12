import 'dart:convert';

import 'package:crypto/crypto.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run tools/license_generator.dart DEVICE_ID [...]');
    return;
  }

  for (final deviceId in args) {
    final normalized = deviceId.trim().toUpperCase();
    if (normalized.length < 8) {
      print('$deviceId: invalid device ID');
      continue;
    }
    final digest = sha256
        .convert(utf8.encode('wirespot-v1:$normalized'))
        .toString()
        .toUpperCase();
    final license =
        'WS-${normalized.substring(0, 8)}-${digest.substring(0, 16)}';
    print('$normalized => $license');
  }
}
