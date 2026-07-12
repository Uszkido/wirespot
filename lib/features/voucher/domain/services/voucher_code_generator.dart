import 'dart:math';

import '../entities/voucher_encoding_settings.dart';

class VoucherCodeGenerator {
  VoucherCodeGenerator({Random? random}) : _random = random ?? Random.secure();

  static const _numeric = '0123456789';
  static const _numericSafe = '23456789';
  static const _alphabetic = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _alphabeticSafe = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const _alphanumeric = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const _alphanumericSafe = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  final Random _random;

  String username({
    required String prefix,
    required int length,
    VoucherCharacterSet characterSet = VoucherCharacterSet.alphanumeric,
    bool excludeConfusingCharacters = true,
  }) {
    return '$prefix${code(length: length, characterSet: characterSet, excludeConfusingCharacters: excludeConfusingCharacters)}';
  }

  String password({
    required int length,
    VoucherCharacterSet characterSet = VoucherCharacterSet.alphanumeric,
    bool excludeConfusingCharacters = true,
  }) {
    return code(
      length: length,
      characterSet: characterSet,
      excludeConfusingCharacters: excludeConfusingCharacters,
    );
  }

  String code({
    required int length,
    required VoucherCharacterSet characterSet,
    required bool excludeConfusingCharacters,
  }) {
    if (length < 4) {
      throw ArgumentError.value(length, 'length', 'Must be at least 4');
    }
    final alphabet = _alphabetFor(
      characterSet,
      excludeConfusingCharacters: excludeConfusingCharacters,
    );

    return String.fromCharCodes(
      List.generate(length, (_) {
        return alphabet.codeUnitAt(_random.nextInt(alphabet.length));
      }),
    );
  }

  String _alphabetFor(
    VoucherCharacterSet characterSet, {
    required bool excludeConfusingCharacters,
  }) {
    return switch (characterSet) {
      VoucherCharacterSet.numeric =>
        excludeConfusingCharacters ? _numericSafe : _numeric,
      VoucherCharacterSet.alphabetic =>
        excludeConfusingCharacters ? _alphabeticSafe : _alphabetic,
      VoucherCharacterSet.alphanumeric =>
        excludeConfusingCharacters ? _alphanumericSafe : _alphanumeric,
    };
  }
}
