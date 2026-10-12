import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/settlement.dart';
import '../../data/repositories/settlement_repository.dart';

final settlementRepositoryProvider = Provider<SettlementRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return SettlementRepository(apiClient);
});

final settlementsProvider = FutureProvider.family<List<Settlement>, int>((
  ref,
  groupId,
) async {
  final repository = ref.read(settlementRepositoryProvider);

  return repository.getSettlements(groupId);
});
