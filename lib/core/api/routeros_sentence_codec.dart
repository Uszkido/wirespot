import 'dart:convert';
import 'dart:typed_data';

class RouterOsSentenceCodec {
  const RouterOsSentenceCodec._();

  static List<int> encodeSentence(Iterable<String> words) {
    final bytes = <int>[];
    for (final word in words) {
      final wordBytes = utf8.encode(word);
      bytes
        ..addAll(encodeLength(wordBytes.length))
        ..addAll(wordBytes);
    }
    bytes.add(0);
    return bytes;
  }

  static List<int> encodeLength(int length) {
    if (length < 0x80) {
      return [length];
    }
    if (length < 0x4000) {
      return [
        ((length >> 8) | 0x80) & 0xFF,
        length & 0xFF,
      ];
    }
    if (length < 0x200000) {
      return [
        ((length >> 16) | 0xC0) & 0xFF,
        (length >> 8) & 0xFF,
        length & 0xFF,
      ];
    }
    if (length < 0x10000000) {
      return [
        ((length >> 24) | 0xE0) & 0xFF,
        (length >> 16) & 0xFF,
        (length >> 8) & 0xFF,
        length & 0xFF,
      ];
    }
    return [
      0xF0,
      (length >> 24) & 0xFF,
      (length >> 16) & 0xFF,
      (length >> 8) & 0xFF,
      length & 0xFF,
    ];
  }

  static int decodeLength(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw const FormatException('RouterOS length prefix is empty.');
    }

    final first = bytes.first;
    if ((first & 0x80) == 0x00) {
      return first;
    }
    if ((first & 0xC0) == 0x80) {
      _requireLength(bytes, 2);
      return ((first & 0x3F) << 8) + bytes[1];
    }
    if ((first & 0xE0) == 0xC0) {
      _requireLength(bytes, 3);
      return ((first & 0x1F) << 16) + (bytes[1] << 8) + bytes[2];
    }
    if ((first & 0xF0) == 0xE0) {
      _requireLength(bytes, 4);
      return ((first & 0x0F) << 24) +
          (bytes[1] << 16) +
          (bytes[2] << 8) +
          bytes[3];
    }

    _requireLength(bytes, 5);
    return (bytes[1] << 24) + (bytes[2] << 16) + (bytes[3] << 8) + bytes[4];
  }

  static void _requireLength(Uint8List bytes, int expected) {
    if (bytes.length < expected) {
      throw FormatException(
        'RouterOS length prefix expected $expected bytes, got ${bytes.length}.',
      );
    }
  }
}
