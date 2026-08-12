class RouterCredentials {
  const RouterCredentials({
    required this.username,
    required this.password,
    this.accessToken,
  });

  final String username;
  final String password;
  final String? accessToken;

  Map<String, Object?> toJson() {
    return {
      'username': username,
      'password': password,
      if (accessToken != null) 'accessToken': accessToken,
    };
  }

  factory RouterCredentials.fromJson(Map<String, Object?> json) {
    return RouterCredentials(
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      accessToken: json['accessToken'] as String?,
    );
  }
}
