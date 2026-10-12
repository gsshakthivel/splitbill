class Member {
  const Member({
    required this.userId,
    required this.username,
    required this.role,
  });

  final int userId;
  final String username;
  final String role;

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      role: json['role'] as String,
    );
  }
}
