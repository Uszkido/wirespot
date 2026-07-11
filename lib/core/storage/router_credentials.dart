class RouterCredentials {
  const RouterCredentials({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  Map<String, Object?> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }

  factory RouterCredentials.fromJson(Map<String, Object?> json) {
    return RouterCredentials(
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }
}
