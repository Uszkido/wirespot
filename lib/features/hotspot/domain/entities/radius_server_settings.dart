/// Connection settings for an external RADIUS/FreeRADIUS server.
///
/// The shared secret is intentionally kept on this short-lived setup object;
/// callers must not persist it in a normal router document or backup.
class RadiusServerSettings {
  const RadiusServerSettings({
    required this.address,
    required this.secret,
    this.authenticationPort = 1812,
    this.accountingPort = 1813,
    this.timeoutSeconds = 3,
    this.service = 'hotspot',
  });

  final String address;
  final String secret;
  final int authenticationPort;
  final int accountingPort;
  final int timeoutSeconds;
  final String service;

  List<String> get validationErrors {
    final errors = <String>[];
    if (address.trim().isEmpty) errors.add('Enter the RADIUS server address.');
    if (secret.trim().isEmpty) errors.add('Enter the RADIUS shared secret.');
    if (!_validPort(authenticationPort)) {
      errors.add('Authentication port must be between 1 and 65535.');
    }
    if (!_validPort(accountingPort)) {
      errors.add('Accounting port must be between 1 and 65535.');
    }
    if (timeoutSeconds <= 0) errors.add('RADIUS timeout must be positive.');
    if (service.trim().isEmpty) errors.add('Enter a RADIUS service.');
    return errors;
  }

  Map<String, String> toRouterOsAttributes() => {
    'service': service.trim(),
    'address': address.trim(),
    'secret': secret,
    'authentication-port': '$authenticationPort',
    'accounting-port': '$accountingPort',
    'timeout': '${timeoutSeconds}s',
  };

  static bool _validPort(int port) => port >= 1 && port <= 65535;
}
