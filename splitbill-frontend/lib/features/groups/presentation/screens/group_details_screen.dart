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

  static const _primary = Color(0xFF176B55);
  static const _background = Color(0xFFF6F8F7);
  static const _text = Color(0xFF172B25);
  static const _muted = Color(0xFF75817C);
  static const _border = Color(0xFFE6ECE8);
  static const _danger = Color(0xFFB94141);

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
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFCEAE8),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.person_remove_outlined,
                color: Color(0xFFB94141),
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Remove member?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF172B25),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to remove $username from this group?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF75817C),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF4D6D2)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFB94141),
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'This person will no longer be a member of this group.',
                      style: TextStyle(
                        color: Color(0xFF8F3935),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF172B25),
                    side: const BorderSide(color: Color(0xFFE6ECE8)),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFB94141),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();

                    await ref
                        .read(groupNotifierProvider.notifier)
                        .removeMember(groupId: groupId, userId: userId);

                    if (!context.mounted) return;

                    final state = ref.read(groupNotifierProvider);

                    if (state.hasError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error.toString())),
                      );
                      return;
                    }

                    ref.invalidate(groupDetailsProvider(groupId));
                    ref.invalidate(groupBalancesProvider(groupId));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$username removed from the group.'),
                      ),
                    );
                  },
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Remove',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _createExpense(BuildContext context, WidgetRef ref) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CreateExpenseScreen(groupId: groupId)),
    );

    if (created == true) {
      ref.invalidate(expensesProvider(groupId));
      ref.invalidate(groupBalancesProvider(groupId));
    }
  }

  Future<void> _settleUp(
    BuildContext context,
    WidgetRef ref,
    dynamic members,
  ) async {
    final settled = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SettleUpScreen(groupId: groupId, members: members),
      ),
    );

    if (settled == true) {
      ref.invalidate(groupBalancesProvider(groupId));
      ref.invalidate(settlementsProvider(groupId));
    }
  }

  Future<void> _editExpense(
    BuildContext context,
    WidgetRef ref,
    int expenseId,
  ) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            EditExpenseScreen(groupId: groupId, expenseId: expenseId),
      ),
    );

    if (updated == true) {
      ref.invalidate(expensesProvider(groupId));
      ref.invalidate(groupBalancesProvider(groupId));
    }
  }

  Future<void> _deleteExpense(
    BuildContext context,
    WidgetRef ref,
    int expenseId,
    String description,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,

      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        title: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFCEAE8),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFB94141),
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Delete expense?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF172B25),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  color: Color(0xFF75817C),
                  fontSize: 14,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Are you sure you want to delete '),
                  TextSpan(
                    text: '"$description"',
                    style: const TextStyle(
                      color: Color(0xFF172B25),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF4D6D2)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFB94141),
                    size: 20,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: TextStyle(
                        color: Color(0xFF8F3935),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF172B25),
                    side: const BorderSide(color: Color(0xFFE6ECE8)),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFB94141),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref
        .read(expenseNotifierProvider.notifier)
        .deleteExpense(groupId, expenseId);

    ref.invalidate(expensesProvider(groupId));
    ref.invalidate(groupBalancesProvider(groupId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(groupDetailsProvider(groupId));
    final currentUserId = ref.watch(authNotifierProvider).value?.id;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Group details',
          style: TextStyle(color: _text, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () => _createExpense(context, ref),
            tooltip: 'Add expense',
            style: IconButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: groupState.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _primary)),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 44, color: _muted),
                const SizedBox(height: 12),
                const Text(
                  'Couldn’t load this group',
                  style: TextStyle(
                    color: _text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _muted),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      ref.invalidate(groupDetailsProvider(groupId)),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (group) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
                children: [
                  _GroupHeader(
                    name: group.name,
                    id: group.id,
                    memberCount: group.members.length,
                  ),
                  const SizedBox(height: 28),
                  _SectionHeading(
                    title: 'Members',
                    subtitle: '${group.members.length} people in this group',
                    trailing: TextButton.icon(
                      onPressed: () =>
                          _showAddMemberDialog(context, ref, groupId),
                      icon: const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 18,
                      ),
                      label: const Text('Add'),
                      style: TextButton.styleFrom(foregroundColor: _primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Panel(
                    child: group.members.isEmpty
                        ? const _EmptyMessage(
                            icon: Icons.people_outline_rounded,
                            message: 'No members in this group yet.',
                          )
                        : Column(
                            children: [
                              for (
                                var i = 0;
                                i < group.members.length;
                                i++
                              ) ...[
                                if (i > 0)
                                  const Divider(height: 1, color: _border),
                                Builder(
                                  builder: (context) {
                                    final member = group.members[i];
                                    final isCurrentUser =
                                        member.userId == currentUserId;

                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 4,
                                          ),
                                      leading: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: const Color(
                                          0xFFE2F3EA,
                                        ),
                                        child: Text(
                                          member.username.isNotEmpty
                                              ? member.username[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: _primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        isCurrentUser
                                            ? '${member.username} (You)'
                                            : member.username,
                                        style: const TextStyle(
                                          color: _text,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          member.role,
                                          style: const TextStyle(
                                            color: _muted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      trailing: IconButton(
                                        tooltip: 'Remove member',
                                        onPressed: () =>
                                            _showRemoveMemberDialog(
                                              context,
                                              ref,
                                              groupId,
                                              member.userId,
                                              member.username,
                                            ),
                                        icon: const Icon(
                                          Icons.person_remove_outlined,
                                          color: _muted,
                                          size: 21,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                  ),
                  const SizedBox(height: 28),
                  const _SectionHeading(
                    title: 'Balances',
                    subtitle: 'See who owes and who gets paid',
                  ),
                  const SizedBox(height: 12),
                  Consumer(
                    builder: (context, ref, child) {
                      final balancesState = ref.watch(
                        groupBalancesProvider(groupId),
                      );

                      return balancesState.when(
                        loading: () => const _LoadingPanel(),
                        error: (error, stackTrace) => _ErrorPanel(
                          message: error.toString(),
                          onRetry: () =>
                              ref.invalidate(groupBalancesProvider(groupId)),
                        ),
                        data: (balances) {
                          if (balances.isEmpty) {
                            return const _Panel(
                              child: _EmptyMessage(
                                icon: Icons.account_balance_wallet_outlined,
                                message: 'No balances available yet.',
                              ),
                            );
                          }

                          final currentUserBalance = balances
                              .where((b) => b.userId == currentUserId)
                              .firstOrNull;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (currentUserBalance != null)
                                _YourBalanceCard(
                                  balance: currentUserBalance.balance,
                                  onSettle: currentUserBalance.balance < 0
                                      ? () => _settleUp(
                                          context,
                                          ref,
                                          group.members,
                                        )
                                      : null,
                                ),
                              const SizedBox(height: 10),
                              _Panel(
                                child: Column(
                                  children: [
                                    for (
                                      var i = 0;
                                      i < balances.length;
                                      i++
                                    ) ...[
                                      if (i > 0)
                                        const Divider(
                                          height: 1,
                                          color: _border,
                                        ),
                                      Builder(
                                        builder: (context) {
                                          final balance = balances[i];
                                          final member = group.members
                                              .where(
                                                (m) =>
                                                    m.userId == balance.userId,
                                              )
                                              .firstOrNull;

                                          if (member == null) {
                                            return const SizedBox.shrink();
                                          }

                                          final owes = balance.balance < 0;
                                          final settled = balance.balance == 0;

                                          return ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 3,
                                                ),
                                            leading: CircleAvatar(
                                              backgroundColor: settled
                                                  ? const Color(0xFFF0F2F1)
                                                  : owes
                                                  ? const Color(0xFFFFE9E7)
                                                  : const Color(0xFFE2F3EA),
                                              child: Icon(
                                                settled
                                                    ? Icons.check_rounded
                                                    : owes
                                                    ? Icons.arrow_upward_rounded
                                                    : Icons
                                                          .arrow_downward_rounded,
                                                size: 19,
                                                color: settled
                                                    ? _muted
                                                    : owes
                                                    ? _danger
                                                    : _primary,
                                              ),
                                            ),
                                            title: Text(
                                              member.username,
                                              style: const TextStyle(
                                                color: _text,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            subtitle: Text(
                                              settled
                                                  ? 'All settled'
                                                  : owes
                                                  ? 'Owes the group'
                                                  : 'Gets back',
                                              style: const TextStyle(
                                                color: _muted,
                                                fontSize: 12,
                                              ),
                                            ),
                                            trailing: Text(
                                              '₹${balance.balance.abs().toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: settled
                                                    ? _muted
                                                    : owes
                                                    ? _danger
                                                    : _primary,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 14),
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
                    icon: const Icon(Icons.history_rounded),
                    label: const Text('View settlement history'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primary,
                      side: const BorderSide(color: _border),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SectionHeading(
                    title: 'Expenses',
                    subtitle: 'Shared spending in this group',
                    trailing: TextButton.icon(
                      onPressed: () => _createExpense(context, ref),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add expense'),
                      style: TextButton.styleFrom(foregroundColor: _primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer(
                    builder: (context, ref, child) {
                      final expensesState = ref.watch(
                        expensesProvider(groupId),
                      );

                      return expensesState.when(
                        loading: () => const _LoadingPanel(),
                        error: (error, stackTrace) => _ErrorPanel(
                          message: error.toString(),
                          onRetry: () =>
                              ref.invalidate(expensesProvider(groupId)),
                        ),
                        data: (expenses) {
                          if (expenses.isEmpty) {
                            return const _Panel(
                              child: _EmptyMessage(
                                icon: Icons.receipt_long_outlined,
                                message: 'No expenses yet. Add the first expense to get started.',
                              ),
                            );
                          }

                          return _Panel(
                            child: Column(
                              children: [
                                for (var i = 0; i < expenses.length; i++) ...[
                                  if (i > 0)
                                    const Divider(height: 1, color: _border),
                                  Builder(
                                    builder: (context) {
                                      final expense = expenses[i];

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                onTap: () => context.push(
                                                  '/groups/$groupId/expenses/${expense.id}',
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 44,
                                                        height: 44,
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFFEAF0ED,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                13,
                                                              ),
                                                        ),
                                                        child: const Icon(
                                                          Icons
                                                              .receipt_long_rounded,
                                                          color: _primary,
                                                          size: 22,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              expense
                                                                  .description,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                color: _text,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              'My share: ₹${expense.myShare.toStringAsFixed(2)}',
                                                              style:
                                                                  const TextStyle(
                                                                    color:
                                                                        _muted,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '₹${expense.amount.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    color: _text,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                      tooltip: 'Edit expense',
                                                      onPressed: () =>
                                                          _editExpense(
                                                            context,
                                                            ref,
                                                            expense.id,
                                                          ),
                                                      icon: const Icon(
                                                        Icons.edit_outlined,
                                                        size: 19,
                                                      ),
                                                      color: _muted,
                                                    ),
                                                    IconButton(
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                      tooltip: 'Delete expense',
                                                      onPressed: () =>
                                                          _deleteExpense(
                                                            context,
                                                            ref,
                                                            expense.id,
                                                            expense.description,
                                                          ),
                                                      icon: const Icon(
                                                        Icons
                                                            .delete_outline_rounded,
                                                        size: 19,
                                                      ),
                                                      color: _danger,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.name,
    required this.id,
    required this.memberCount,
  });

  final String name;
  final int id;
  final int memberCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF176B55), Color(0xFF104C3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '$memberCount ${memberCount == 1 ? 'member' : 'members'} · Group #$id',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF172B25),
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
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
        if (trailing != null) ?trailing,
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE6ECE8)),
      ),
      child: child,
    );
  }
}

class _YourBalanceCard extends StatelessWidget {
  const _YourBalanceCard({required this.balance, this.onSettle});

  final double balance;
  final VoidCallback? onSettle;

  @override
  Widget build(BuildContext context) {
    final owes = balance < 0;
    final settled = balance == 0;
    final color = settled
        ? const Color(0xFF75817C)
        : owes
        ? const Color(0xFFB94141)
        : const Color(0xFF176B55);
    final background = settled
        ? const Color(0xFFF0F2F1)
        : owes
        ? const Color(0xFFFFF0EE)
        : const Color(0xFFE7F5EC);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: color.withValues(alpha: 0.13)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settled
                      ? 'Your balance'
                      : owes
                      ? 'You owe'
                      : 'You are owed',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '₹${balance.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                  ),
                ),
              ],
            ),
          ),
          if (onSettle != null)
            FilledButton(
              onPressed: onSettle,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF176B55),
                foregroundColor: Colors.white,
              ),
              child: const Text('Settle up'),
            ),
        ],
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(icon, size: 32, color: const Color(0xFF8B9992)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF75817C),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const _Panel(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF176B55)),
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFB94141)),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
