import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill_frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:splitbill_frontend/features/groups/presentation/providers/group_provider.dart';

import '../../../groups/data/models/group.dart';
import '../notifiers/home_notifier.dart';

final homeNotifierProvider = AsyncNotifierProvider<HomeNotifier, List<Group>>(
  HomeNotifier.new,
);

class OverallBalance {
  const OverallBalance({required this.netBalance});

  final double netBalance;

  double get amount => netBalance.abs();

  String get status {
    if (netBalance > 0) return 'You are owed';
    if (netBalance < 0) return 'You owe';
    return 'All settled';
  }
}

final overallBalanceProvider = FutureProvider<OverallBalance>((ref) async {
  final currentUserId = ref.watch(authNotifierProvider).value?.id;

  if (currentUserId == null) {
    return const OverallBalance(netBalance: 0);
  }

  final groups = await ref.watch(homeNotifierProvider.future);
  final repository = ref.read(groupRepositoryProvider);

  double totalBalance = 0;

  final balancesPerGroup = await Future.wait(
    groups.map((group) => repository.getBalances(group.id)),
  );

  for (final balances in balancesPerGroup) {
    for (final balance in balances) {
      if (balance.userId == currentUserId) {
        totalBalance += balance.balance;
        break;
      }
    }
  }

  return OverallBalance(netBalance: totalBalance);
});
