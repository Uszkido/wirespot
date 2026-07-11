import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/utils/byte_format.dart';

void main() {
  test('formats byte values compactly', () {
    expect(ByteFormat.compact(512), '512 B');
    expect(ByteFormat.compact(1024), '1.0 KB');
    expect(ByteFormat.compact(1024 * 1024 * 12), '12 MB');
  });
}
