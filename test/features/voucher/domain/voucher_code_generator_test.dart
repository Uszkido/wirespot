import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/voucher/domain/services/voucher_code_generator.dart';

void main() {
  test('generates prefixed usernames and fixed-length passwords', () {
    final generator = VoucherCodeGenerator();

    final username = generator.username(prefix: 'WS', length: 8);
    final password = generator.password(length: 6);

    expect(username.startsWith('WS'), isTrue);
    expect(username.length, 10);
    expect(password.length, 6);
  });
}
