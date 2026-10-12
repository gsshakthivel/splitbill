import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:splitbill_frontend/features/expenses/data/models/create_expense_request.dart';
import 'package:splitbill_frontend/features/expenses/data/models/expense_details.dart';
import 'package:splitbill_frontend/features/expenses/data/models/expense_split_request.dart';
import 'package:splitbill_frontend/features/expenses/presentation/notifiers/expense_notifier.dart';
import 'package:splitbill_frontend/features/expenses/presentation/providers/expense_details_provider.dart';
import 'package:splitbill_frontend/features/groups/presentation/notifiers/group_details_notifier.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  const EditExpenseScreen({
    super.key,
    required this.groupId,
    required this.expenseId,
  });

  final int groupId;
  final int expenseId;

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  int? _paidBy;
  final Set<int> _selectedMembers = {};

  bool _initialized = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _initializeForm(ExpenseDetails expense) {
    if (_initialized) {
      return;
    }

    _descriptionController.text = expense.description;
    _amountController.text = expense.amount.toStringAsFixed(2);
    _paidBy = expense.paidBy;

    _selectedMembers.addAll(expense.splits.map((split) => split.userId));

    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(expenseNotifierProvider, (previous, next) {
      next.when(
        data: (_) {
          if (previous?.isLoading == true) {
            Navigator.of(context).pop(true);
          }
        },
        loading: () {},
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.toString())));
        },
      );
    });

    final expenseState = ref.watch(
      expenseDetailsProvider((
        groupId: widget.groupId,
        expenseId: widget.expenseId,
      )),
    );

    final groupState = ref.watch(groupDetailsProvider(widget.groupId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expense')),
      body: expenseState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(error.toString(), textAlign: TextAlign.center)),
        data: (expense) {
          _initializeForm(expense);

          return groupState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text(error.toString(), textAlign: TextAlign.center),
            ),
            data: (group) {
              final members = group.members;
              final isSubmitting = ref.watch(expenseNotifierProvider).isLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      initialValue: _paidBy,
                      decoration: const InputDecoration(
                        labelText: 'Paid by',
                        border: OutlineInputBorder(),
                      ),
                      items: members.map((member) {
                        return DropdownMenuItem<int>(
                          value: member.userId,
                          child: Text(member.username),
                        );
                      }).toList(),
                      onChanged: isSubmitting
                          ? null
                          : (value) {
                              setState(() {
                                _paidBy = value;
                              });
                            },
                    ),

                    const SizedBox(height: 24),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Split between',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    ...members.map((member) {
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(member.username),
                        value: _selectedMembers.contains(member.userId),
                        onChanged: isSubmitting
                            ? null
                            : (selected) {
                                setState(() {
                                  if (selected == true) {
                                    _selectedMembers.add(member.userId);
                                  } else {
                                    _selectedMembers.remove(member.userId);
                                  }
                                });
                              },
                      );
                    }),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final description = _descriptionController.text
                                    .trim();

                                final amount = double.tryParse(
                                  _amountController.text.trim(),
                                );

                                if (description.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter a description.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (amount == null || amount <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter a valid amount.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (_paidBy == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please select who paid.'),
                                    ),
                                  );
                                  return;
                                }

                                if (_selectedMembers.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select at least one member.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final request = CreateExpenseRequest(
                                  paidBy: _paidBy!,
                                  amount: amount,
                                  description: description,
                                  splitType: expense.splitType,
                                  splits: _selectedMembers
                                      .map(
                                        (userId) =>
                                            ExpenseSplitRequest(userId: userId),
                                      )
                                      .toList(),
                                );

                                await ref
                                    .read(expenseNotifierProvider.notifier)
                                    .updateExpense(
                                      widget.groupId,
                                      widget.expenseId,
                                      request,
                                    );
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Update Expense'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
