import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/authentication/domain/services/pin_hash_service.dart';

void main() {
  test('hash verifies matching PIN and rejects different PIN', () {
    final service = PinHashService();
    final salt = service.generateSalt();
    final hash = service.hashPin(pin: '1234', salt: salt);

    expect(
      service.verify(pin: '1234', salt: salt, expectedHash: hash),
      isTrue,
    );
    expect(
      service.verify(pin: '4321', salt: salt, expectedHash: hash),
      isFalse,
    );
  });
}
