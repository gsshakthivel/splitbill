import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill_frontend/features/groups/data/models/member.dart';
import 'package:intl/intl.dart';
import 'package:splitbill_frontend/features/settlements/presentation/providers/settlement_provider.dart';

class SettlementHistoryScreen extends ConsumerWidget {
  const SettlementHistoryScreen({
    super.key,
    required this.groupId,
    required this.members,
  });

  final int groupId;

  final List<Member> members;

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime.toLocal());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settlementsState = ref.watch(settlementsProvider(groupId));

    return Scaffold(
      appBar: AppBar(title: const Text('Settlement History')),
      body: settlementsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Could not load settlements: $error'),
          ),
        ),
        data: (settlements) {
          if (settlements.isEmpty) {
            return const Center(child: Text('No settlements yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: settlements.length,
            itemBuilder: (context, index) {
              final settlement = settlements[index];

              final fromMember = members.where(
                (member) => member.userId == settlement.fromUserId,
              );

              final toMember = members.where(
                (member) => member.userId == settlement.toUserId,
              );

              final fromName = fromMember.isNotEmpty
                  ? fromMember.first.username
                  : 'Unknown user';

              final toName = toMember.isNotEmpty
                  ? toMember.first.username
                  : 'Unknown user';

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.payments)),
                  title: Text('₹${settlement.amount.toStringAsFixed(2)}'),
                  subtitle: Text(
                    'From $fromName '
                    'to $toName\n'
                    '${_formatDateTime(settlement.createdAt)}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
