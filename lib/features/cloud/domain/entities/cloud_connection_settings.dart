class CloudConnectionSettings {
  const CloudConnectionSettings({
    required this.apiBaseUrl,
    this.organizationId,
    this.allowInsecureDevelopment = false,
  });

  final String apiBaseUrl;
  final String? organizationId;
  final bool allowInsecureDevelopment;

  Uri get apiBaseUri {
    final value = apiBaseUrl.trim();
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError.value(
        apiBaseUrl,
        'apiBaseUrl',
        'Use an absolute API URL.',
      );
    }
    if (uri.scheme != 'https' &&
        !(allowInsecureDevelopment && uri.scheme == 'http')) {
      throw ArgumentError.value(apiBaseUrl, 'apiBaseUrl', 'HTTPS is required.');
    }
    return Uri.parse(value.endsWith('/') ? value : '$value/');
  }

  CloudConnectionSettings copyWith({
    String? apiBaseUrl,
    String? organizationId,
    bool? allowInsecureDevelopment,
  }) {
    return CloudConnectionSettings(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      organizationId: organizationId ?? this.organizationId,
      allowInsecureDevelopment:
          allowInsecureDevelopment ?? this.allowInsecureDevelopment,
    );
  }

  Map<String, Object?> toJson() => {
    'apiBaseUrl': apiBaseUrl,
    'organizationId': organizationId,
    'allowInsecureDevelopment': allowInsecureDevelopment,
  };

  factory CloudConnectionSettings.fromJson(Map<String, Object?> json) {
    return CloudConnectionSettings(
      apiBaseUrl: json['apiBaseUrl'] as String? ?? '',
      organizationId: json['organizationId'] as String?,
      allowInsecureDevelopment:
          json['allowInsecureDevelopment'] as bool? ?? false,
    );
  }
}
