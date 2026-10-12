import 'package:splitbill_frontend/app/core/network/api_client.dart';
import 'package:splitbill_frontend/features/expenses/data/models/create_expense_request.dart';
import 'package:splitbill_frontend/features/expenses/data/models/expense_details.dart';

import '../models/expense.dart';

class ExpenseRepository {
  ExpenseRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Expense>> getExpenses(int groupId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/groups/$groupId/expenses',
    );

    final expenses = response.data!['expenses'] as List<dynamic>;

    return expenses
        .map((json) => Expense.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> createExpense(int groupId, CreateExpenseRequest request) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/groups/$groupId/expenses',
      data: request.toJson(),
    );
  }

  Future<ExpenseDetails> getExpenseDetails(int groupId, int expenseId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/groups/$groupId/expenses/$expenseId',
    );

    final expense = response.data!['expense'] as Map<String, dynamic>;

    return ExpenseDetails.fromJson(expense);
  }

  Future<void> updateExpense(
    int groupId,
    int expenseId,
    CreateExpenseRequest request,
  ) async {
    await _apiClient.patch<Map<String, dynamic>>(
      '/groups/$groupId/expenses/$expenseId',
      data: request.toJson(),
    );
  }

  Future<void> deleteExpense(int groupId, int expenseId) async {
    await _apiClient.delete<Map<String, dynamic>>(
      '/groups/$groupId/expenses/$expenseId',
    );
  }
}
