import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PinHashService {
  PinHashService({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  String generateSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String hashPin({required String pin, required String salt}) {
    final input = utf8.encode('$salt:$pin');
    return sha256.convert(input).toString();
  }

  bool verify({
    required String pin,
    required String salt,
    required String expectedHash,
  }) {
    return hashPin(pin: pin, salt: salt) == expectedHash;
  }
}
