class HotspotSetupInspection {
  const HotspotSetupInspection({
    required this.serverExists,
    required this.profileExists,
  });

  final bool serverExists;
  final bool profileExists;

  String get serverAction =>
      serverExists ? 'Update existing server' : 'Create server';

  String get profileAction =>
      profileExists ? 'Reuse existing profile' : 'Create profile';
}
