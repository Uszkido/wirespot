class RouterDiscoveryResult {
  const RouterDiscoveryResult({
    required this.host,
    this.identity,
    this.macAddress,
    this.version,
    this.boardName,
    this.interfaceName,
  });

  final String host;
  final String? identity;
  final String? macAddress;
  final String? version;
  final String? boardName;
  final String? interfaceName;

  String get displayName =>
      (identity == null || identity!.trim().isEmpty) ? host : identity!.trim();
}
