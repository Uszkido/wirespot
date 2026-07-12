class HotspotSetupInput {
  const HotspotSetupInput({
    required this.serverName,
    required this.interfaceName,
    required this.serverProfileName,
    this.hotspotAddress,
    this.dnsName,
    this.addressPool,
    this.htmlDirectory,
    this.loginByCookie = true,
    this.loginByHttpPap = true,
    this.loginByHttps = false,
    this.useRadius = false,
    this.disabled = false,
  });

  final String serverName;
  final String interfaceName;
  final String serverProfileName;
  final String? hotspotAddress;
  final String? dnsName;
  final String? addressPool;
  final String? htmlDirectory;
  final bool loginByCookie;
  final bool loginByHttpPap;
  final bool loginByHttps;
  final bool useRadius;
  final bool disabled;

  Map<String, String> toServerProfileAttributes() {
    return {
      'name': serverProfileName.trim(),
      if (_hasText(hotspotAddress)) 'hotspot-address': hotspotAddress!.trim(),
      if (_hasText(dnsName)) 'dns-name': dnsName!.trim(),
      if (_hasText(htmlDirectory)) 'html-directory': htmlDirectory!.trim(),
      'login-by': _loginByModes().join(','),
      'use-radius': useRadius ? 'yes' : 'no',
    };
  }

  Map<String, String> toServerAttributes() {
    return {
      'name': serverName.trim(),
      'interface': interfaceName.trim(),
      'profile': serverProfileName.trim(),
      if (_hasText(addressPool)) 'address-pool': addressPool!.trim(),
      'disabled': disabled ? 'yes' : 'no',
    };
  }

  List<String> _loginByModes() {
    final modes = <String>[];
    if (loginByCookie) {
      modes.add('cookie');
    }
    if (loginByHttpPap) {
      modes.add('http-pap');
    }
    if (loginByHttps) {
      modes.add('https');
    }
    return modes.isEmpty ? const ['http-pap'] : modes;
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
