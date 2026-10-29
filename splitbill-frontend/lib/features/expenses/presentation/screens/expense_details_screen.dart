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

  static const _primary = Color(0xFF176B55);
  static const _background = Color(0xFFF6F8F7);
  static const _text = Color(0xFF172B25);
  static const _muted = Color(0xFF75817C);
  static const _border = Color(0xFFE6ECE8);

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
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Expense details',
          style: TextStyle(color: _text, fontWeight: FontWeight.w800),
        ),
      ),
      body: expenseState.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _primary)),
        error: (error, stackTrace) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(
            expenseDetailsProvider((groupId: groupId, expenseId: expenseId)),
          ),
        ),
        data: (expense) {
          final members = groupState.asData?.value.members ?? [];

          String memberName(int userId) {
            for (final member in members) {
              if (member.userId == userId) return member.username;
            }
            return 'Unknown user';
          }

          String initials(String name) {
            final trimmed = name.trim();
            return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
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
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'TOTAL EXPENSE',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          expense.description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Created ${_formatDateTime(expense.createdAt)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  const _SectionHeading(
                    title: 'Payment information',
                    subtitle: 'Who paid and how this expense is split',
                  ),
                  const SizedBox(height: 12),
                  _Panel(
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 5,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE2F3EA),
                            child: const Icon(
                              Icons.person_rounded,
                              color: _primary,
                            ),
                          ),
                          title: const Text(
                            'Paid by',
                            style: TextStyle(color: _muted, fontSize: 12),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              memberName(expense.paidBy),
                              style: const TextStyle(
                                color: _text,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: _border),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 5,
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE8ECFF),
                            child: Icon(
                              Icons.call_split_rounded,
                              color: Color(0xFF4E5FBF),
                            ),
                          ),
                          title: const Text(
                            'Split type',
                            style: TextStyle(color: _muted, fontSize: 12),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              expense.splitType,
                              style: const TextStyle(
                                color: _text,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: _border),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 5,
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFFFEEDB),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFFB56A1B),
                            ),
                          ),
                          title: const Text(
                            'Created by',
                            style: TextStyle(color: _muted, fontSize: 12),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              memberName(expense.createdBy),
                              style: const TextStyle(
                                color: _text,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  _SectionHeading(
                    title: 'Expense split',
                    subtitle:
                        '${expense.splits.length} ${expense.splits.length == 1 ? 'participant' : 'participants'} sharing this expense',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F3EA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SHARES',
                        style: TextStyle(
                          color: _primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (expense.splits.isEmpty)
                    const _Panel(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: _EmptySplits(),
                      ),
                    )
                  else
                    _Panel(
                      child: Column(
                        children: [
                          for (var i = 0; i < expense.splits.length; i++) ...[
                            if (i > 0)
                              const Divider(
                                height: 1,
                                color: _border,
                                indent: 16,
                                endIndent: 16,
                              ),
                            Builder(
                              builder: (context) {
                                final split = expense.splits[i];
                                final name = memberName(split.userId);

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 5,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFEAF0ED),
                                    child: Text(
                                      initials(name),
                                      style: const TextStyle(
                                        color: _primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      color: _text,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Share of expense',
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  trailing: Text(
                                    '₹${split.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: _primary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3EF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: _primary,
                          size: 21,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Each participant’s amount above represents their recorded share of this expense.',
                            style: TextStyle(
                              color: _text,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
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
        ?trailing,
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

class _EmptySplits extends StatelessWidget {
  const _EmptySplits();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.people_outline_rounded, size: 34, color: Color(0xFF75817C)),
        SizedBox(height: 10),
        Text(
          'No participant shares available.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF75817C), fontSize: 13),
        ),
      ],
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
              'Couldn’t load expense details',
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
