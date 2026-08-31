class WireGuardConfig {
  const WireGuardConfig({
    required this.name,
    required this.interfaceConfig,
    required this.peers,
    required this.rawConfig,
  });

  final String name;
  final WireGuardInterfaceConfig interfaceConfig;
  final List<WireGuardPeerConfig> peers;
  final String rawConfig;

  factory WireGuardConfig.parse({
    required String name,
    required String config,
  }) {
    if (name.trim().isEmpty) {
      throw const FormatException('WireGuard tunnel name is required.');
    }

    final parsed = _parseSections(config);
    final interfaceValues = parsed.interfaceValues;
    if (interfaceValues == null) {
      throw const FormatException('WireGuard config is missing [Interface].');
    }

    final peers = parsed.peerValues
        .map(WireGuardPeerConfig.fromValues)
        .toList();
    if (peers.isEmpty) {
      throw const FormatException('WireGuard config must include a [Peer].');
    }

    return WireGuardConfig(
      name: name.trim(),
      interfaceConfig: WireGuardInterfaceConfig.fromValues(interfaceValues),
      peers: peers,
      rawConfig: config,
    );
  }
}

class WireGuardInterfaceConfig {
  const WireGuardInterfaceConfig({
    required this.privateKey,
    required this.addresses,
    this.dnsServers = const [],
    this.listenPort,
    this.mtu,
  });

  final String privateKey;
  final List<String> addresses;
  final List<String> dnsServers;
  final int? listenPort;
  final int? mtu;

  factory WireGuardInterfaceConfig.fromValues(Map<String, String> values) {
    final normalized = {
      for (final entry in values.entries) entry.key.toLowerCase(): entry.value,
    };
    final privateKey = normalized['privatekey'];
    final address = normalized['address'];
    if (privateKey == null || privateKey.isEmpty) {
      throw const FormatException(
        'WireGuard interface private key is missing.',
      );
    }
    if (address == null || address.isEmpty) {
      throw const FormatException('WireGuard interface address is missing.');
    }

    return WireGuardInterfaceConfig(
      privateKey: privateKey,
      addresses: _splitCsv(address),
      dnsServers: _splitCsv(normalized['dns']),
      listenPort: int.tryParse(normalized['listenport'] ?? ''),
      mtu: int.tryParse(normalized['mtu'] ?? ''),
    );
  }
}

class WireGuardPeerConfig {
  const WireGuardPeerConfig({
    required this.publicKey,
    required this.allowedIps,
    this.endpoint,
    this.presharedKey,
    this.persistentKeepalive,
  });

  final String publicKey;
  final List<String> allowedIps;
  final String? endpoint;
  final String? presharedKey;
  final int? persistentKeepalive;

  factory WireGuardPeerConfig.fromValues(Map<String, String> values) {
    final normalized = {
      for (final entry in values.entries) entry.key.toLowerCase(): entry.value,
    };
    final publicKey = normalized['publickey'];
    final allowedIps = normalized['allowedips'];
    if (publicKey == null || publicKey.isEmpty) {
      throw const FormatException('WireGuard peer public key is missing.');
    }
    if (allowedIps == null || allowedIps.isEmpty) {
      throw const FormatException('WireGuard peer allowed IPs are missing.');
    }

    return WireGuardPeerConfig(
      publicKey: publicKey,
      allowedIps: _splitCsv(allowedIps),
      endpoint: normalized['endpoint'],
      presharedKey: normalized['presharedkey'],
      persistentKeepalive: int.tryParse(normalized['persistentkeepalive'] ?? ''),
    );
  }
}

_ParsedWireGuardSections _parseSections(String config) {
  Map<String, String>? interfaceValues;
  final peerValues = <Map<String, String>>[];
  Map<String, String>? currentValues;
  String? currentSection;

  for (final rawLine in config.split(RegExp(r'\r?\n'))) {
    final line = rawLine.split('#').first.split(';').first.trim();
    if (line.isEmpty) {
      continue;
    }

    if (line.startsWith('[') && line.endsWith(']')) {
      final sectionName = line.substring(1, line.length - 1).trim();
      currentSection = sectionName.toLowerCase();
      currentValues = <String, String>{};
      if (currentSection == 'interface') {
        interfaceValues = currentValues;
      } else if (currentSection == 'peer') {
        peerValues.add(currentValues);
      }
      continue;
    }

    final separator = line.indexOf('=');
    if (separator < 1 || currentSection == null || currentValues == null) {
      continue;
    }

    if (currentSection == 'interface' || currentSection == 'peer') {
      currentValues[line.substring(0, separator).trim()] = line
          .substring(separator + 1)
          .trim();
    }
  }

  return _ParsedWireGuardSections(
    interfaceValues: interfaceValues,
    peerValues: peerValues,
  );
}

class _ParsedWireGuardSections {
  const _ParsedWireGuardSections({
    required this.interfaceValues,
    required this.peerValues,
  });

  final Map<String, String>? interfaceValues;
  final List<Map<String, String>> peerValues;
}

List<String> _splitCsv(String? value) {
  if (value == null || value.trim().isEmpty) {
    return const [];
  }
  return value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}
