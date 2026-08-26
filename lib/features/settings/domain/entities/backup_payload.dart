class BackupPayload {
  const BackupPayload({
    required this.version,
    required this.exportedAt,
    required this.settings,
    required this.printers,
    this.routers = const [],
    this.hotspotProfiles = const [],
    this.routerGroups = const [],
    this.wireGuardConfigs = const [],
  });

  final int version;
  final DateTime exportedAt;
  final Map<String, String> settings;
  final List<Map<String, Object?>> printers;
  final List<Map<String, Object?>> routers;
  final List<Map<String, Object?>> hotspotProfiles;
  final List<Map<String, Object?>> routerGroups;
  final List<Map<String, Object?>> wireGuardConfigs;

  Map<String, Object?> toJson() {
    return {
      'version': version,
      'exportedAt': exportedAt.toIso8601String(),
      'settings': settings,
      'printers': printers,
      'routers': routers,
      'hotspotProfiles': hotspotProfiles,
      'routerGroups': routerGroups,
      'wireGuardConfigs': wireGuardConfigs,
    };
  }

  static BackupPayload fromJson(Map<String, Object?> json) {
    final rawSettings = json['settings'];
    final rawPrinters = json['printers'];
    final rawRouters = json['routers'];
    final rawProfiles = json['hotspotProfiles'];
    final rawGroups = json['routerGroups'];
    final rawWg = json['wireGuardConfigs'];
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
      printers: _parseList(rawPrinters),
      routers: _parseList(rawRouters),
      hotspotProfiles: _parseList(rawProfiles),
      routerGroups: _parseList(rawGroups),
      wireGuardConfigs: _parseList(rawWg),
    );
  }

  static List<Map<String, Object?>> _parseList(Object? raw) {
    if (raw is! List) {
      return const [];
    }
    return [
      for (final item in raw)
        if (item is Map)
          {
            for (final entry in item.entries)
              entry.key.toString(): entry.value,
          },
    ];
  }
}
