import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:splitbill_frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:splitbill_frontend/features/groups/data/models/balance.dart';
import 'package:splitbill_frontend/features/groups/data/respositories/group_respository.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return GroupRepository(apiClient);
});

final groupBalancesProvider = FutureProvider.family<List<Balance>, int>((
  ref,
  groupId,
) async {
  final repository = ref.read(groupRepositoryProvider);

  return repository.getBalances(groupId);
});
