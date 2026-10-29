import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:splitbill_frontend/features/groups/data/models/member.dart';
import 'package:splitbill_frontend/features/settlements/presentation/providers/settlement_provider.dart';

class SettlementHistoryScreen extends ConsumerWidget {
  const SettlementHistoryScreen({
    super.key,
    required this.groupId,
    required this.members,
  });

  final int groupId;
  final List<Member> members;

  static const _primary = Color(0xFF176B55);
  static const _background = Color(0xFFF6F8F7);
  static const _text = Color(0xFF172B25);
  static const _muted = Color(0xFF75817C);
  static const _border = Color(0xFFE6ECE8);

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime.toLocal());
  }

  String _memberName(int userId) {
    for (final member in members) {
      if (member.userId == userId) {
        return member.username;
      }
    }
    return 'Unknown user';
  }

  String _initials(String name) {
    if (name == 'Unknown user' || name.trim().isEmpty) {
      return '?';
    }

    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settlementsState = ref.watch(settlementsProvider(groupId));

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _text,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Settlement History',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: settlementsState.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _primary)),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCEAE8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_off_outlined,
                      color: Color(0xFFB5473C),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Could not load settlements',
                    textAlign: TextAlign.center,
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
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.invalidate(settlementsProvider(groupId));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
        data: (settlements) {
          final totalSettled = settlements.fold<double>(
            0,
            (total, settlement) => total + settlement.amount,
          );

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: settlements.isEmpty
                  ? _EmptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF176B55), Color(0xFF27876B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(11),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Settlement summary',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Total settled',
                                style: TextStyle(
                                  color: Color(0xFFD9EEE6),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '₹${totalSettled.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  '${settlements.length} ${settlements.length == 1 ? 'settlement' : 'settlements'} recorded',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),
                        const Text(
                          'Recent settlements',
                          style: TextStyle(
                            color: _text,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'A record of payments between group members.',
                          style: TextStyle(color: _muted, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ...settlements.map((settlement) {
                          final fromName = _memberName(settlement.fromUserId);
                          final toName = _memberName(settlement.toUserId);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE7F3EE),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Icon(
                                        Icons.check_circle_outline,
                                        color: _primary,
                                        size: 25,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Settlement completed',
                                            style: TextStyle(
                                              color: _text,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDateTime(
                                              settlement.createdAt,
                                            ),
                                            style: const TextStyle(
                                              color: _muted,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '₹${settlement.amount.toStringAsFixed(2)}',
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          color: _primary,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 17,
                                      backgroundColor: const Color(0xFFE7F3EE),
                                      child: Text(
                                        _initials(fromName),
                                        style: const TextStyle(
                                          color: _primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Text(
                                        fromName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: _text,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: _muted,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    CircleAvatar(
                                      radius: 17,
                                      backgroundColor: const Color(0xFFE8EFFD),
                                      child: Text(
                                        _initials(toName),
                                        style: const TextStyle(
                                          color: Color(0xFF365DA8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Text(
                                        toName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: _text,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F3EE),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.payments_outlined,
                size: 42,
                color: Color(0xFF176B55),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No settlements yet',
              style: TextStyle(
                color: Color(0xFF172B25),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'When someone settles a balance, the payment history will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF75817C), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
