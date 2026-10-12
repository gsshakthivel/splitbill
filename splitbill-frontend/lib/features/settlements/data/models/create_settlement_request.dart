class CreateSettlementRequest {
  const CreateSettlementRequest({required this.toUserId, required this.amount});

  final int toUserId;
  final double amount;

  Map<String, dynamic> toJson() {
    return {'toUserId': toUserId, 'amount': amount};
  }
}
