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

  static BackupPayload fromJson(Map<String, Object?> json) {
    final rawSettings = json['settings'];
    final rawPrinters = json['printers'];
    final rawVersion = json['version'];
    return BackupPayload(
      version: rawVersion is int ? rawVersion : 1,
      exportedAt:
          DateTime.tryParse(json['exportedAt']?.toString() ?? '') ??
          DateTime.now(),
      settings: rawSettings is Map
          ? {
              for (final entry in rawSettings.entries)
                entry.key.toString(): entry.value.toString(),
            }
          : const {},
      printers: rawPrinters is List
          ? [
              for (final item in rawPrinters)
                if (item is Map)
                  {
                    for (final entry in item.entries)
                      entry.key.toString(): entry.value,
                  },
            ]
          : const [],
    );
  }
}
