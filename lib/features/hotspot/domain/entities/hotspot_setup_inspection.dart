class HotspotSetupInspection {
  const HotspotSetupInspection({
    required this.serverExists,
    required this.profileExists,
    this.radiusExists = false,
  });

  final bool serverExists;
  final bool profileExists;
  final bool radiusExists;

  String get serverAction =>
      serverExists ? 'Update existing server' : 'Create server';

  String get profileAction =>
      profileExists ? 'Reuse existing profile' : 'Create profile';

  String get radiusAction =>
      radiusExists ? 'Update existing RADIUS server' : 'Add RADIUS server';
}
