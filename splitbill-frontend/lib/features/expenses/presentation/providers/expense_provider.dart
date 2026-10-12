import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/expense.dart';
import '../../data/repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return ExpenseRepository(apiClient);
});

final expensesProvider = FutureProvider.family<List<Expense>, int>((
  ref,
  groupId,
) async {
  final repository = ref.read(expenseRepositoryProvider);

  return repository.getExpenses(groupId);
});
