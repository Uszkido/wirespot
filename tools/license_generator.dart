import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    stdout.writeln(
      'Usage: dart run tools/license_generator.dart DEVICE_ID [...]',
    );
    return;
  }

  for (final deviceId in args) {
    final normalized = deviceId.trim().toUpperCase();
    if (normalized.length < 8) {
      stdout.writeln('$deviceId: invalid device ID');
      continue;
    }
    final digest = sha256
        .convert(utf8.encode('wirespot-v1:$normalized'))
        .toString()
        .toUpperCase();
    final license =
        'WS-${normalized.substring(0, 8)}-${digest.substring(0, 16)}';
    stdout.writeln('$normalized => $license');
  }
}
