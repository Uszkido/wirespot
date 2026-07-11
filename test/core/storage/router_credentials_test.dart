import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/storage/router_credentials.dart';

void main() {
  test('RouterCredentials serializes without changing fields', () {
    const credentials = RouterCredentials(
      username: 'admin',
      password: 'secret',
    );

    final encoded = jsonEncode(credentials.toJson());
    final decoded = RouterCredentials.fromJson(
      jsonDecode(encoded) as Map<String, Object?>,
    );

    expect(decoded.username, 'admin');
    expect(decoded.password, 'secret');
  });
}
