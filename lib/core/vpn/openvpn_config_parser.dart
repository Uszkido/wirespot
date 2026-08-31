class OpenVpnConfig {
  const OpenVpnConfig({
    required this.name,
    required this.rawConfig,
    this.remoteHost,
    this.remotePort = 1194,
    this.transportProtocol = 'udp',
    this.cipher,
    this.requiresUserAuth = false,
    this.hasCaCertificate = false,
  });

  final String name;
  final String rawConfig;
  final String? remoteHost;
  final int remotePort;
  final String transportProtocol;
  final String? cipher;
  final bool requiresUserAuth;
  final bool hasCaCertificate;

  factory OpenVpnConfig.parse({
    required String name,
    required String configText,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const FormatException('OpenVPN profile name is required.');
    }
    if (configText.trim().isEmpty) {
      throw const FormatException('OpenVPN configuration text is empty.');
    }

    String? remoteHost;
    int remotePort = 1194;
    String transportProtocol = 'udp';
    String? cipher;
    bool requiresUserAuth = false;
    final hasCaCertificate =
        configText.contains('<ca>') && configText.contains('</ca>');

    for (final rawLine in configText.split(RegExp(r'\r?\n'))) {
      final line = rawLine.split('#').first.split(';').first.trim();
      if (line.isEmpty) {
        continue;
      }

      final parts = line.split(RegExp(r'\s+'));
      final directive = parts.first.toLowerCase();

      if (directive == 'remote' && parts.length >= 2) {
        remoteHost = parts[1];
        if (parts.length >= 3) {
          remotePort = int.tryParse(parts[2]) ?? 1194;
        }
        if (parts.length >= 4) {
          transportProtocol = parts[3].toLowerCase();
        }
      } else if (directive == 'proto' && parts.length >= 2) {
        transportProtocol = parts[1].toLowerCase().replaceAll(
          RegExp(r'4|6'),
          '',
        );
      } else if (directive == 'port' && parts.length >= 2) {
        remotePort = int.tryParse(parts[1]) ?? 1194;
      } else if ((directive == 'cipher' || directive == 'data-ciphers') &&
          parts.length >= 2) {
        cipher = parts[1];
      } else if (directive == 'auth-user-pass') {
        requiresUserAuth = true;
      }
    }

    return OpenVpnConfig(
      name: trimmedName,
      rawConfig: configText,
      remoteHost: remoteHost,
      remotePort: remotePort,
      transportProtocol: transportProtocol,
      cipher: cipher,
      requiresUserAuth: requiresUserAuth,
      hasCaCertificate: hasCaCertificate,
    );
  }
}
