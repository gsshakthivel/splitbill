class AuthResponse {
  const AuthResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  final int id;
  final String name;
  final String email;
  final String token;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
    );
  }
}
