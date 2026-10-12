import 'expense_split_request.dart';

class CreateExpenseRequest {
  const CreateExpenseRequest({
    required this.paidBy,
    required this.amount,
    required this.description,
    required this.splitType,
    required this.splits,
  });

  final int paidBy;
  final double amount;
  final String description;
  final String splitType;
  final List<ExpenseSplitRequest> splits;

  Map<String, dynamic> toJson() {
    return {
      'paidBy': paidBy,
      'amount': amount,
      'description': description,
      'splitType': splitType,
      'splits': splits.map((split) => split.toJson()).toList(),
    };
  }
}
