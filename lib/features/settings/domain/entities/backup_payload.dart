class BackupPayload {
  const BackupPayload({
    required this.version,
    required this.exportedAt,
    required this.settings,
    required this.printers,
  });

  final int version;
  final DateTime exportedAt;
  final Map<String, String> settings;
  final List<Map<String, Object?>> printers;

  Map<String, Object?> toJson() {
    return {
      'version': version,
      'exportedAt': exportedAt.toIso8601String(),
      'settings': settings,
      'printers': printers,
    };
  }
}
