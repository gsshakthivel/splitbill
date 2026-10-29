import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:splitbill_frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:splitbill_frontend/features/groups/data/models/member.dart';
import 'package:splitbill_frontend/features/groups/presentation/providers/group_provider.dart';
import 'package:splitbill_frontend/features/settlements/data/models/create_settlement_request.dart';
import 'package:splitbill_frontend/features/settlements/presentation/notifiers/settlement_notifier.dart';
import 'package:splitbill_frontend/features/settlements/presentation/providers/settlement_provider.dart';

class SettleUpScreen extends ConsumerStatefulWidget {
  const SettleUpScreen({
    super.key,
    required this.groupId,
    required this.members,
  });

  final int groupId;
  final List<Member> members;

  @override
  ConsumerState<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends ConsumerState<SettleUpScreen> {
  static const _primary = Color(0xFF176B55);
  static const _background = Color(0xFFF6F8F7);
  static const _text = Color(0xFF172B25);
  static const _muted = Color(0xFF75817C);
  static const _border = Color(0xFFE6ECE8);
  static const _danger = Color(0xFFB94141);

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  int? _selectedUserId;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(authNotifierProvider).value?.id;
    final balancesState = ref.watch(groupBalancesProvider(widget.groupId));
    final settlementState = ref.watch(settlementNotifierProvider);
    final isSubmitting = settlementState.isLoading;

    final recipientMembers = balancesState.maybeWhen(
      data: (balances) {
        final owedUserIds = balances
            .where((balance) => balance.balance > 0)
            .map((balance) => balance.userId)
            .toSet();

        return widget.members
            .where(
              (member) =>
                  member.userId != currentUserId &&
                  owedUserIds.contains(member.userId),
            )
            .toList();
      },
      orElse: () => <Member>[],
    );

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          color: _text,
          tooltip: 'Back',
        ),
        title: const Text(
          'Settle Up',
          style: TextStyle(
            color: _text,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: balancesState.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _primary)),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 44, color: _muted),
                const SizedBox(height: 16),
                const Text(
                  'Could not load balances',
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
                  style: const TextStyle(color: _muted, height: 1.4),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.invalidate(groupBalancesProvider(widget.groupId));
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (balances) {
          if (recipientMembers.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F4EF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: _primary,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'You’re all settled!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _text,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'There are no eligible members to pay in this group right now.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _muted,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => context.pop(),
                            style: FilledButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Back to group'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          final selectedMember = recipientMembers
              .where((member) => member.userId == _selectedUserId)
              .firstOrNull;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: _primary,
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
                                  Icons.payments_outlined,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Settle your balance',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Record a payment you made to another group member.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.82),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              if (selectedMember != null) ...[
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Paying ${selectedMember.username}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Payment details',
                          style: TextStyle(
                            color: _text,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: _border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(
                                icon: Icons.person_outline_rounded,
                                label: 'Pay to',
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<int>(
                                initialValue:
                                    recipientMembers.any(
                                      (member) =>
                                          member.userId == _selectedUserId,
                                    )
                                    ? _selectedUserId
                                    : null,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  hintText: 'Select a group member',
                                  filled: true,
                                  fillColor: _background,
                                  prefixIcon: const Icon(
                                    Icons.account_circle_outlined,
                                    color: _muted,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: _border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: _border,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: _primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: _danger,
                                    ),
                                  ),
                                ),
                                items: recipientMembers
                                    .map(
                                      (member) => DropdownMenuItem<int>(
                                        value: member.userId,
                                        child: Text(
                                          member.username,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: isSubmitting
                                    ? null
                                    : (userId) {
                                        setState(() {
                                          _selectedUserId = userId;
                                        });
                                      },
                                validator: (userId) {
                                  if (userId == null) {
                                    return 'Please select a member.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),
                              const _FieldLabel(
                                icon: Icons.currency_rupee_rounded,
                                label: 'Amount',
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _amountController,
                                enabled: !isSubmitting,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: const TextStyle(
                                  color: _text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  prefixText: '₹ ',
                                  prefixStyle: const TextStyle(
                                    color: _primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  filled: true,
                                  fillColor: _background,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 18,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: _border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: _border,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: _primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: _danger,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  final amount = double.tryParse(
                                    value?.trim() ?? '',
                                  );

                                  if (amount == null ||
                                      !amount.isFinite ||
                                      amount <= 0) {
                                    return 'Enter an amount greater than zero.';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: _muted,
                                    size: 17,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Only record payments that have actually been made.',
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }

                                    final userId = _selectedUserId;
                                    if (userId == null) return;

                                    final amount = double.parse(
                                      _amountController.text.trim(),
                                    );

                                    final request = CreateSettlementRequest(
                                      toUserId: userId,
                                      amount: amount,
                                    );

                                    await ref
                                        .read(
                                          settlementNotifierProvider.notifier,
                                        )
                                        .createSettlement(
                                          widget.groupId,
                                          request,
                                        );

                                    if (!context.mounted) return;

                                    final state = ref.read(
                                      settlementNotifierProvider,
                                    );

                                    if (state.hasError) {
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              state.error.toString(),
                                            ),
                                          ),
                                        );
                                      return;
                                    }

                                    ref.invalidate(
                                      settlementsProvider(widget.groupId),
                                    );
                                    ref.invalidate(
                                      groupBalancesProvider(widget.groupId),
                                    );

                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Settlement created successfully.',
                                          ),
                                        ),
                                      );

                                    context.pop(true);
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: _primary.withValues(
                                alpha: 0.45,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            icon: isSubmitting
                                ? const SizedBox.shrink()
                                : const Icon(
                                    Icons.check_circle_outline_rounded,
                                  ),
                            label: isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Record settlement',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF176B55)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF172B25),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
