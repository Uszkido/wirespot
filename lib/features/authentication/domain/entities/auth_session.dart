class AuthSession {
  const AuthSession({required this.token, required this.createdAt});

  final String token;
  final DateTime createdAt;
}
