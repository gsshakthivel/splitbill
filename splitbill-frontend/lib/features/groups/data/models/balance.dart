class Balance {
  const Balance({required this.userId, required this.balance});

  final int userId;
  final double balance;

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      userId: json['userId'] as int,
      balance: double.parse(json['balance'] as String),
    );
  }
}
