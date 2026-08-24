class CloudSession {
  const CloudSession({required this.accessToken, required this.expiresAt});

  final String accessToken;
  final DateTime expiresAt;

  bool get isExpired => !expiresAt.isAfter(DateTime.now());

  Map<String, Object?> toJson() => {
    'accessToken': accessToken,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
  };

  factory CloudSession.fromJson(Map<String, Object?> json) {
    final expiry = DateTime.tryParse(json['expiresAt'] as String? ?? '');
    if (expiry == null) {
      throw const FormatException('Cloud session expiry is invalid.');
    }
    return CloudSession(
      accessToken: json['accessToken'] as String? ?? '',
      expiresAt: expiry,
    );
  }
}
