import 'dart:io';

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
    final digest = _licenseDigest(normalized);
    final license =
        'VEXEL-${normalized.substring(0, 4)}-'
        '${digest.substring(0, 4)}';
    stdout.writeln('$normalized => $license');
  }
}

String _licenseDigest(String deviceId) {
  var hash = 0x811C9DC5;
  final input = 'wirespot-v2:$deviceId';
  for (final codeUnit in input.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  final first = hash.toRadixString(16).padLeft(8, '0');
  final second = ((hash ^ 0xA5A5A5A5) & 0xFFFFFFFF)
      .toRadixString(16)
      .padLeft(8, '0');
  return '$first$second'.toUpperCase();
}
