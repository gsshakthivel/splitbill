import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/expense_details.dart';
import 'expense_provider.dart';

final expenseDetailsProvider =
    FutureProvider.family<ExpenseDetails, ({int groupId, int expenseId})>((
      ref,
      params,
    ) async {
      final repository = ref.read(expenseRepositoryProvider);

      return repository.getExpenseDetails(params.groupId, params.expenseId);
    });
