class ExpenseSplit {
  const ExpenseSplit({required this.userId, required this.amount});

  final int userId;
  final double amount;

  factory ExpenseSplit.fromJson(Map<String, dynamic> json) {
    return ExpenseSplit(
      userId: json['userId'] as int,
      amount: double.parse(json['amount'] as String),
    );
  }
}
