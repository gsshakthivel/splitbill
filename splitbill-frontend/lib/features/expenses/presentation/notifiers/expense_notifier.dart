import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/create_expense_request.dart';
import '../providers/expense_provider.dart';

final expenseNotifierProvider = AsyncNotifierProvider<ExpenseNotifier, void>(
  ExpenseNotifier.new,
);

class ExpenseNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createExpense(int groupId, CreateExpenseRequest request) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(expenseRepositoryProvider);

      await repository.createExpense(groupId, request);
    });
  }

  Future<void> updateExpense(
    int groupId,
    int expenseId,
    CreateExpenseRequest request,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(expenseRepositoryProvider);

      await repository.updateExpense(groupId, expenseId, request);
    });
  }

  Future<void> deleteExpense(int groupId, int expenseId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(expenseRepositoryProvider);

      await repository.deleteExpense(groupId, expenseId);
    });
  }
}
