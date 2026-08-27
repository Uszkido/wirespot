class MikroTikScriptGeneratorService {
  const MikroTikScriptGeneratorService();

  /// Generates clean MikroTik RouterOS terminal commands to auto-configure WireSpot API access.
  String generateSetupScript({
    required String username,
    required String password,
    int apiPort = 8728,
    bool enableSsl = false,
    bool isRouterOsV7 = true,
  }) {
    _validate(username, password, apiPort);
    final safeUsername = _quote(username);
    final safePassword = _quote(password);
    final buffer = StringBuffer()
      ..writeln(
        '# --- WireSpot Auto-Provisioning Script for MikroTik RouterOS ---',
      )
      ..writeln(
        '/user group add name=wirespot policy=api,read,write,test comment="WireSpot Managed Access"',
      )
      ..writeln(
        '/user add name="$safeUsername" group=wirespot password="$safePassword" comment="WireSpot API User"',
      )
      ..writeln('/ip service set api disabled=no port=$apiPort');

    if (enableSsl) {
      buffer.writeln('/ip service set api-ssl disabled=no port=${apiPort + 1}');
    }

    if (isRouterOsV7) {
      buffer.writeln(
        '/ip service set rest disabled=no port=8080 comment="WireSpot RouterOS v7 REST API"',
      );
    }

    buffer.writeln(
      '/ip hotspot user profile add name="wirespot-default" shared-users=1',
    );
    return buffer.toString();
  }

  /// Generates a single compact copy-paste command for MikroTik Terminal.
  String generateOneLiner({
    required String username,
    required String password,
    int apiPort = 8728,
    bool isRouterOsV7 = true,
  }) {
    _validate(username, password, apiPort);
    final safeUsername = _quote(username);
    final safePassword = _quote(password);
    final restCmd = isRouterOsV7
        ? '; /ip service set rest disabled=no port=8080'
        : '';
    return '/user group add name=wirespot policy=api,read,write,test; '
        '/user add name="$safeUsername" group=wirespot password="$safePassword"; '
        '/ip service set api disabled=no port=$apiPort$restCmd; '
        '/ip hotspot user profile add name="wirespot-default" shared-users=1';
  }

  static void _validate(String username, String password, int apiPort) {
    if (username.trim().isEmpty || username.contains(RegExp(r'[\r\n]'))) {
      throw ArgumentError.value(
        username,
        'username',
        'must be a non-empty single line',
      );
    }
    if (password.isEmpty || password.contains(RegExp(r'[\r\n]'))) {
      throw ArgumentError.value(
        password,
        'password',
        'must be a non-empty single line',
      );
    }
    if (apiPort < 1 || apiPort > 65535) {
      throw ArgumentError.value(
        apiPort,
        'apiPort',
        'must be between 1 and 65535',
      );
    }
  }

  static String _quote(String value) => value
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll(r'$', r'\$');
}
