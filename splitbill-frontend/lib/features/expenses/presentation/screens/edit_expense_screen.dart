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

  static const _primary = Color(0xFF176B55);
  static const _background = Color(0xFFF6F8F7);
  static const _text = Color(0xFF172B25);
  static const _muted = Color(0xFF75817C);
  static const _border = Color(0xFFE6ECE8);

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
    if (_initialized) return;

    _descriptionController.text = expense.description;
    _amountController.text = expense.amount.toStringAsFixed(2);
    _paidBy = expense.paidBy;
    _selectedMembers.addAll(expense.splits.map((split) => split.userId));
    _initialized = true;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submitUpdate(ExpenseDetails expense) async {
    final description = _descriptionController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (description.isEmpty) {
      _showMessage('Please enter a description.');
      return;
    }

    if (amount == null || !amount.isFinite || amount <= 0) {
      _showMessage('Please enter a valid amount.');
      return;
    }

    if (_paidBy == null) {
      _showMessage('Please select who paid.');
      return;
    }

    if (_selectedMembers.isEmpty) {
      _showMessage('Please select at least one member.');
      return;
    }

    final request = CreateExpenseRequest(
      paidBy: _paidBy!,
      amount: amount,
      description: description,
      splitType: expense.splitType,
      splits: _selectedMembers
          .map((userId) => ExpenseSplitRequest(userId: userId))
          .toList(),
    );

    await ref
        .read(expenseNotifierProvider.notifier)
        .updateExpense(widget.groupId, widget.expenseId, request);
  }

  @override
  Widget build(BuildContext context) {
    final expenseDetailsKey = (
      groupId: widget.groupId,
      expenseId: widget.expenseId,
    );

    final expenseState = ref.watch(expenseDetailsProvider(expenseDetailsKey));
    final groupState = ref.watch(groupDetailsProvider(widget.groupId));
    final isSubmitting = ref.watch(expenseNotifierProvider).isLoading;

    ref.listen<AsyncValue<void>>(expenseNotifierProvider, (previous, next) {
      next.when(
        data: (_) {
          if (previous?.isLoading == true && context.mounted) {
            ref.invalidate(expenseDetailsProvider(expenseDetailsKey));
            ref.invalidate(groupDetailsProvider(widget.groupId));
            Navigator.of(context).pop(true);
          }
        },
        loading: () {},
        error: (error, stackTrace) => _showMessage(error.toString()),
      );
    });

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Edit expense',
          style: TextStyle(color: _text, fontWeight: FontWeight.w800),
        ),
      ),
      body: expenseState.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _primary)),
        error: (error, stackTrace) => _ErrorState(
          message: error.toString(),
          onRetry: () =>
              ref.invalidate(expenseDetailsProvider(expenseDetailsKey)),
        ),
        data: (expense) {
          _initializeForm(expense);

          return groupState.when(
            loading: () =>
                const Center(child: CircularProgressIndicator(color: _primary)),
            error: (error, stackTrace) => _ErrorState(
              message: error.toString(),
              onRetry: () =>
                  ref.invalidate(groupDetailsProvider(widget.groupId)),
            ),
            data: (group) {
              final members = group.members;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF176B55), Color(0xFF104C3D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EDITING AMOUNT',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.6,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text(
                                  '₹',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    enabled: !isSubmitting,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1,
                                    ),
                                    cursorColor: Colors.white,
                                    decoration: const InputDecoration(
                                      hintText: '0.00',
                                      hintStyle: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 38,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Group: ${group.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      const _SectionTitle(
                        title: 'Expense details',
                        subtitle: 'Update what this payment was for.',
                      ),
                      const SizedBox(height: 12),
                      _FormCard(
                        child: TextField(
                          controller: _descriptionController,
                          enabled: !isSubmitting,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'e.g. Dinner, groceries, rent',
                            prefixIcon: Icon(Icons.receipt_long_outlined),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      const _SectionTitle(
                        title: 'Paid by',
                        subtitle: 'Who paid the bill?',
                      ),
                      const SizedBox(height: 12),
                      _FormCard(
                        child: DropdownButtonFormField<int>(
                          initialValue: members.any((m) => m.userId == _paidBy)
                              ? _paidBy
                              : null,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline_rounded),
                            labelText: 'Select payer',
                            border: InputBorder.none,
                          ),
                          items: members.map((member) {
                            return DropdownMenuItem<int>(
                              value: member.userId,
                              child: Text(
                                member.username,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: isSubmitting
                              ? null
                              : (value) => setState(() => _paidBy = value),
                        ),
                      ),
                      const SizedBox(height: 26),
                      _SectionTitle(
                        title: 'Split between',
                        subtitle:
                            '${_selectedMembers.length} of ${members.length} members selected',
                        trailing: TextButton(
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    if (_selectedMembers.length ==
                                        members.length) {
                                      _selectedMembers.clear();
                                    } else {
                                      _selectedMembers
                                        ..clear()
                                        ..addAll(members.map((m) => m.userId));
                                    }
                                  });
                                },
                          child: Text(
                            _selectedMembers.length == members.length
                                ? 'Clear all'
                                : 'Select all',
                            style: const TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _FormCard(
                        child: Column(
                          children: [
                            for (var i = 0; i < members.length; i++) ...[
                              if (i > 0)
                                const Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                  color: _border,
                                ),
                              Builder(
                                builder: (context) {
                                  final member = members[i];
                                  final selected = _selectedMembers.contains(
                                    member.userId,
                                  );

                                  return CheckboxListTile(
                                    value: selected,
                                    onChanged: isSubmitting
                                        ? null
                                        : (value) {
                                            setState(() {
                                              if (value == true) {
                                                _selectedMembers.add(
                                                  member.userId,
                                                );
                                              } else {
                                                _selectedMembers.remove(
                                                  member.userId,
                                                );
                                              }
                                            });
                                          },
                                    activeColor: _primary,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 3,
                                    ),
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                    secondary: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: selected
                                          ? const Color(0xFFE2F3EA)
                                          : const Color(0xFFF0F2F1),
                                      child: Text(
                                        member.username.isNotEmpty
                                            ? member.username[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: selected ? _primary : _muted,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      member.username,
                                      style: const TextStyle(
                                        color: _text,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: const Text(
                                      'Included in split',
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3EF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: _primary,
                              size: 21,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                expense.splitType == 'equal'
                                    ? 'This expense uses an equal split. The selected members determine how the expense is shared.'
                                    : 'Split type: ${expense.splitType}. Your existing split type will be preserved.',
                                style: const TextStyle(
                                  color: _text,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () => _submitUpdate(expense),
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 19,
                                  height: 19,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_rounded),
                          label: Text(
                            isSubmitting
                                ? 'Updating expense...'
                                : 'Save changes',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF172B25),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF75817C), fontSize: 12),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6ECE8)),
      ),
      child: child,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: Color(0xFF75817C),
            ),
            const SizedBox(height: 12),
            const Text(
              'Couldn’t load the expense',
              style: TextStyle(
                color: Color(0xFF172B25),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF75817C)),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF176B55),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
