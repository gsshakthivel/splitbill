import 'expense_split.dart';

class ExpenseDetails {
  const ExpenseDetails({
    required this.expenseId,
    required this.description,
    required this.groupId,
    required this.amount,
    required this.paidBy,
    required this.createdBy,
    required this.splitType,
    required this.createdAt,
    required this.splits,
  });

  final int expenseId;
  final String description;
  final int groupId;
  final double amount;
  final int paidBy;
  final int createdBy;
  final String splitType;
  final DateTime createdAt;
  final List<ExpenseSplit> splits;

  factory ExpenseDetails.fromJson(Map<String, dynamic> json) {
    return ExpenseDetails(
      expenseId: json['expenseId'] as int,
      description: json['description'] as String,
      groupId: json['groupId'] as int,
      amount: double.parse(json['amount'] as String),
      paidBy: json['paidBy'] as int,
      createdBy: json['createdBy'] as int,
      splitType: json['splitType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      splits: (json['splits'] as List<dynamic>)
          .map((json) => ExpenseSplit.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }
}
