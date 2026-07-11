class IdGenerator {
  const IdGenerator._();

  static String timestampId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}
