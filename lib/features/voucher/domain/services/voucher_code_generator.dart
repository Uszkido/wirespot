import 'dart:math';

class VoucherCodeGenerator {
  VoucherCodeGenerator({Random? random}) : _random = random ?? Random.secure();

  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  final Random _random;

  String username({
    required String prefix,
    required int length,
  }) {
    return '$prefix${_code(length)}';
  }

  String password({required int length}) => _code(length);

  String _code(int length) {
    if (length < 4) {
      throw ArgumentError.value(length, 'length', 'Must be at least 4');
    }

    return String.fromCharCodes(
      List.generate(length, (_) {
        return _alphabet.codeUnitAt(_random.nextInt(_alphabet.length));
      }),
    );
  }
}
