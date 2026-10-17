class RadiusSubscriber {
  const RadiusSubscriber({
    required this.username,
    required this.password,
    required this.planName,
    required this.rateLimit,
    this.sessionTimeoutSeconds,
    this.expiration,
    this.disabled = false,
    this.dataLimitBytes,
  });

  final String username;
  final String password;
  final String planName;
  final String rateLimit;
  final int? sessionTimeoutSeconds;
  final DateTime? expiration;
  final bool disabled;
  final int? dataLimitBytes;

  List<String> get validationErrors {
    final errors = <String>[];
    if (username.trim().isEmpty) errors.add('Enter a subscriber username.');
    if (password.isEmpty) errors.add('Enter a subscriber password.');
    if (planName.trim().isEmpty) errors.add('Select a subscriber plan.');
    if (rateLimit.trim().isEmpty)
      errors.add('Set a download/upload rate limit.');
    if (sessionTimeoutSeconds != null && sessionTimeoutSeconds! <= 0) {
      errors.add('Session timeout must be positive.');
    }
    if (dataLimitBytes != null && dataLimitBytes! <= 0) {
      errors.add('Data limit must be positive.');
    }
    return errors;
  }

  /// Returns a FreeRADIUS `mods-config/files/authorize` entry.
  /// The password is intentionally included because this output is only for a
  /// secure server-side provisioning path or an explicitly requested export.
  String toAuthorizeEntry() {
    final attributes = <String>[
      'Cleartext-Password := "${_escape(password)}"',
      'Mikrotik-Rate-Limit := "${_escape(rateLimit)}"',
      if (sessionTimeoutSeconds != null)
        'Session-Timeout := $sessionTimeoutSeconds',
      if (expiration != null)
        'Expiration := "${_formatExpiration(expiration!)}"',
      if (dataLimitBytes != null) 'Max-All-Session := $dataLimitBytes',
      if (disabled) 'Auth-Type := Reject',
    ];
    return '${_escape(username)}  ${attributes.join(',\n    ')}';
  }

  static String _escape(String value) => value.replaceAll('"', '\\"');

  static String _formatExpiration(DateTime value) {
    final utc = value.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')} ${utc.hour.toString().padLeft(2, '0')}:${utc.minute.toString().padLeft(2, '0')}';
  }
}
