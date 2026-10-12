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
      appBar: AppBar(title: const Text('Settle Up')),
      body: balancesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Could not load balances: $error'),
          ),
        ),
        data: (balances) {
          if (recipientMembers.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No eligible members to settle with.'),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Pay to',
                      border: OutlineInputBorder(),
                    ),
                    items: recipientMembers
                        .map(
                          (member) => DropdownMenuItem<int>(
                            value: member.userId,
                            child: Text(member.username),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    enabled: !isSubmitting,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount (₹)',
                      border: OutlineInputBorder(),
                      prefixText: '₹ ',
                    ),
                    validator: (value) {
                      final amount = double.tryParse(value?.trim() ?? '');

                      if (amount == null || !amount.isFinite || amount <= 0) {
                        return 'Enter a valid amount greater than zero.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
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
                                .read(settlementNotifierProvider.notifier)
                                .createSettlement(widget.groupId, request);

                            if (!context.mounted) return;

                            final state = ref.read(settlementNotifierProvider);

                            if (state.hasError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error.toString())),
                              );
                              return;
                            }

                            ref.invalidate(settlementsProvider(widget.groupId));
                            ref.invalidate(
                              groupBalancesProvider(widget.groupId),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Settlement created successfully.',
                                ),
                              ),
                            );

                            context.pop(true);
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continue'),
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
