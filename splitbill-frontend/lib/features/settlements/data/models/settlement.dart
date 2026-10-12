class Settlement {
  const Settlement({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.createdAt,
  });

  final int id;
  final int fromUserId;
  final int toUserId;
  final double amount;
  final DateTime createdAt;

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      id: json['id'] as int,
      fromUserId: json['from_user_id'] as int,
      toUserId: json['to_user_id'] as int,
      amount: double.parse(json['amount'].toString()),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory Settlement.fromCreateJson(Map<String, dynamic> json) {
    return Settlement(
      id: json['id'] as int,
      fromUserId: json['fromUserId'] as int,
      toUserId: json['toUserId'] as int,
      amount: double.parse(json['amount'].toString()),
      createdAt: DateTime.now(),
    );
  }
}
