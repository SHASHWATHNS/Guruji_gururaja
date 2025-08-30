class AuthSession {
  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? userRaw;

  const AuthSession({
    required this.success,
    required this.message,
    this.token,
    this.userRaw,
  });

  bool get hasToken => (token != null && token!.isNotEmpty);
}
