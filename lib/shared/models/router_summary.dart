class RouterSummary {
  const RouterSummary({
    required this.id,
    required this.name,
    required this.host,
    this.isOnline = false,
  });

  final String id;
  final String name;
  final String host;
  final bool isOnline;
}
