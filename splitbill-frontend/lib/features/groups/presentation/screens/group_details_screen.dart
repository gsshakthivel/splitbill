import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:splitbill_frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:splitbill_frontend/features/expenses/presentation/notifiers/expense_notifier.dart';
import 'package:splitbill_frontend/features/expenses/presentation/providers/expense_provider.dart';
import 'package:splitbill_frontend/features/expenses/presentation/screens/create_expense_screen.dart';
import 'package:splitbill_frontend/features/expenses/presentation/screens/edit_expense_screen.dart';
import 'package:splitbill_frontend/features/groups/presentation/notifiers/group_notifier.dart';
import 'package:splitbill_frontend/features/groups/presentation/providers/group_provider.dart';
import 'package:splitbill_frontend/features/groups/presentation/screens/add_member_dialog.dart';
import 'package:splitbill_frontend/features/settlements/presentation/providers/settlement_provider.dart';
import 'package:splitbill_frontend/features/settlements/presentation/screens/settle_up_screen.dart';
import 'package:splitbill_frontend/features/settlements/presentation/screens/settlement_history_screen.dart';

import '../notifiers/group_details_notifier.dart';

class GroupDetailsScreen extends ConsumerWidget {
  const GroupDetailsScreen({super.key, required this.groupId});

  final int groupId;

  void _showAddMemberDialog(BuildContext context, WidgetRef ref, int groupId) {
    showDialog(
      context: context,
      builder: (_) => AddMemberDialog(groupId: groupId),
    ).then((addedUser) {
      if (addedUser == null || !context.mounted) return;

      ref.invalidate(groupDetailsProvider(groupId));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member added successfully.')),
      );
    });
  }

  void _showRemoveMemberDialog(
    BuildContext context,
    WidgetRef ref,
    int groupId,
    int userId,
    String username,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove Member'),
          content: Text(
            'Are you sure you want to remove $username from this group?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                await ref
                    .read(groupNotifierProvider.notifier)
                    .removeMember(groupId: groupId, userId: userId);

                if (!context.mounted) {
                  return;
                }

                final state = ref.read(groupNotifierProvider);

                if (state.hasError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error.toString())),
                  );
                  return;
                }

                ref.invalidate(groupDetailsProvider(groupId));

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$username removed from the group.')),
                );
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(groupDetailsProvider(groupId));
    final authState = ref.watch(authNotifierProvider);
    final currentUserId = authState.value?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Details'),
        actions: [
          IconButton(
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => CreateExpenseScreen(groupId: groupId),
                ),
              );

              if (created == true) {
                ref.invalidate(expensesProvider(groupId));
                ref.invalidate(groupBalancesProvider(groupId));
              }
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add Expense',
          ),
        ],
      ),
      body: groupState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(error.toString(), textAlign: TextAlign.center)),
        data: (group) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                group.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('Group ID: ${group.id}'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Members',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _showAddMemberDialog(context, ref, groupId);
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              ...group.members.map(
                (member) => ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(member.username),
                  subtitle: Text(member.role),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    tooltip: 'Remove member',
                    onPressed: () {
                      _showRemoveMemberDialog(
                        context,
                        ref,
                        groupId,
                        member.userId,
                        member.username,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Balances',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Consumer(
                builder: (context, ref, child) {
                  final balancesState = ref.watch(
                    groupBalancesProvider(groupId),
                  );

                  return balancesState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) =>
                        Text(error.toString(), textAlign: TextAlign.center),
                    data: (balances) {
                      if (balances.isEmpty) {
                        return const Text('No balances available.');
                      }

                      final currentUserBalance = balances
                          .where((balance) => balance.userId == currentUserId)
                          .firstOrNull;

                      return Column(
                        children: [
                          if (currentUserBalance != null &&
                              currentUserBalance.balance < 0)
                            ListTile(
                              title: const Text('Your outstanding debt'),
                              subtitle: Text(
                                'You owe ₹${currentUserBalance.balance.abs().toStringAsFixed(2)}',
                              ),
                              trailing: ElevatedButton(
                                onPressed: () async {
                                  final settled = await Navigator.of(context)
                                      .push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) => SettleUpScreen(
                                            groupId: groupId,
                                            members: group.members,
                                          ),
                                        ),
                                      );

                                  if (settled == true) {
                                    ref.invalidate(
                                      groupBalancesProvider(groupId),
                                    );
                                    ref.invalidate(
                                      settlementsProvider(groupId),
                                    );
                                  }
                                },
                                child: const Text('Settle Up'),
                              ),
                            ),
                          ...balances.map((balance) {
                            final member = group.members.firstWhere(
                              (member) => member.userId == balance.userId,
                            );

                            return ListTile(
                              title: Text(member.username),
                              subtitle: Text(
                                balance.balance > 0
                                    ? 'Gets ₹${balance.balance.toStringAsFixed(2)}'
                                    : balance.balance < 0
                                    ? 'Owes ₹${balance.balance.abs().toStringAsFixed(2)}'
                                    : 'Settled',
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettlementHistoryScreen(
                        groupId: groupId,
                        members: group.members,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('View Settlement History'),
              ),

              const SizedBox(height: 24),

              const Text(
                'Expenses',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Consumer(
                builder: (context, ref, child) {
                  final expensesState = ref.watch(expensesProvider(groupId));

                  return expensesState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) =>
                        Text(error.toString(), textAlign: TextAlign.center),
                    data: (expenses) {
                      if (expenses.isEmpty) {
                        return const Text('No expenses yet.');
                      }

                      return Column(
                        children: expenses.map((expense) {
                          return ListTile(
                            title: Text(expense.description),
                            subtitle: Text(
                              'My share: ₹${expense.myShare.toStringAsFixed(2)}',
                            ),
                            onTap: () {
                              final location =
                                  '/groups/$groupId/expenses/${expense.id}';
                              context.push(location);
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('₹${expense.amount.toStringAsFixed(2)}'),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Edit Expense',
                                  onPressed: () async {
                                    final updated = await Navigator.of(context)
                                        .push<bool>(
                                          MaterialPageRoute(
                                            builder: (_) => EditExpenseScreen(
                                              groupId: groupId,
                                              expenseId: expense.id,
                                            ),
                                          ),
                                        );

                                    if (updated == true) {
                                      ref.invalidate(expensesProvider(groupId));
                                      ref.invalidate(
                                        groupBalancesProvider(groupId),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: 'Delete Expense',
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Delete Expense'),
                                          content: Text(
                                            'Are you sure you want to delete "${expense.description}"?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmed != true) {
                                      return;
                                    }

                                    await ref
                                        .read(expenseNotifierProvider.notifier)
                                        .deleteExpense(groupId, expense.id);

                                    ref.invalidate(expensesProvider(groupId));
                                    ref.invalidate(
                                      groupBalancesProvider(groupId),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
