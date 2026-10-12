class ExpenseSplitRequest {
  const ExpenseSplitRequest({required this.userId});

  final int userId;

  Map<String, dynamic> toJson() {
    return {'userId': userId};
  }
}
