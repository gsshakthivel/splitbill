import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:splitbill_frontend/features/groups/presentation/notifiers/group_details_notifier.dart';

import '../providers/expense_details_provider.dart';

class ExpenseDetailsScreen extends ConsumerWidget {
  const ExpenseDetailsScreen({
    super.key,
    required this.groupId,
    required this.expenseId,
  });

  final int groupId;
  final int expenseId;

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime.toLocal());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseState = ref.watch(
      expenseDetailsProvider((groupId: groupId, expenseId: expenseId)),
    );

    final groupState = ref.watch(groupDetailsProvider(groupId));

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Details')),
      body: expenseState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(error.toString(), textAlign: TextAlign.center)),
        data: (expense) {
          final members = groupState.asData?.value.members ?? [];

          String memberName(int userId) {
            for (final member in members) {
              if (member.userId == userId) {
                return member.username;
              }
            }

            return 'Unknown user';
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                expense.description,
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 16),

              ListTile(
                title: const Text('Total Amount'),
                trailing: Text('₹${expense.amount.toStringAsFixed(2)}'),
              ),

              ListTile(
                title: const Text('Paid By'),
                trailing: Text(memberName(expense.paidBy)),
              ),

              ListTile(
                title: const Text('Split Type'),
                trailing: Text(expense.splitType),
              ),

              ListTile(
                title: const Text('Created By'),
                trailing: Text(memberName(expense.createdBy)),
              ),

              ListTile(
                title: const Text('Created At'),
                trailing: Text(_formatDateTime(expense.createdAt)),
              ),

              const SizedBox(height: 16),

              const Text(
                'Splits',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              ...expense.splits.map(
                (split) => ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(memberName(split.userId)),
                  trailing: Text('₹${split.amount.toStringAsFixed(2)}'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
