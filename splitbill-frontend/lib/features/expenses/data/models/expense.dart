class Expense {
  const Expense({
    required this.id,
    required this.description,
    required this.groupId,
    required this.amount,
    required this.paidBy,
    required this.createdBy,
    required this.splitType,
    required this.createdAt,
    required this.myShare,
  });

  final int id;
  final String description;
  final int groupId;
  final double amount;
  final int paidBy;
  final int createdBy;
  final String splitType;
  final DateTime createdAt;
  final double? myShare;

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int,
      description: json['description'] as String,
      groupId: json['group_id'] as int,
      amount: double.parse(json['amount'].toString()),
      paidBy: json['paid_by'] as int,
      createdBy: json['created_by'] as int,
      splitType: json['split_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      myShare: json['my_share'] == null
          ? null
          : double.parse(json['my_share'].toString()),
    );
  }
}
