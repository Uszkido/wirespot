import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/api/routeros_sentence_codec.dart';

void main() {
  test('encodes a RouterOS sentence with terminating zero length word', () {
    final bytes = RouterOsSentenceCodec.encodeSentence([
      '/system/identity/print',
      '=.proplist=name',
    ]);

    expect(bytes.last, 0);
    expect(bytes.first, '/system/identity/print'.length);
  });

  test('round trips RouterOS length boundaries', () {
    for (final length in [0, 1, 127, 128, 16383, 16384, 2097151]) {
      final encoded = Uint8List.fromList(RouterOsSentenceCodec.encodeLength(length));
      expect(RouterOsSentenceCodec.decodeLength(encoded), length);
    }
  });
}
