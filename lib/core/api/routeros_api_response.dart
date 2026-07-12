class RouterOsApiResponse {
  const RouterOsApiResponse({
    required this.records,
    this.doneAttributes = const {},
  });

  final List<Map<String, String>> records;
  final Map<String, String> doneAttributes;

  bool get isEmpty => records.isEmpty;
}

class RouterOsReply {
  const RouterOsReply({required this.type, required this.attributes});

  final String type;
  final Map<String, String> attributes;

  bool get isRecord => type == '!re';
  bool get isDone => type == '!done';
  bool get isTrap => type == '!trap';
  bool get isFatal => type == '!fatal';
}
