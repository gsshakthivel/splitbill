import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill_frontend/features/settlements/presentation/providers/settlement_provider.dart';

import '../../data/models/create_settlement_request.dart';
import '../../data/models/settlement.dart';

final settlementNotifierProvider =
    AsyncNotifierProvider<SettlementNotifier, Settlement?>(
      SettlementNotifier.new,
    );

class SettlementNotifier extends AsyncNotifier<Settlement?> {
  @override
  Future<Settlement?> build() async {
    return null;
  }

  Future<void> createSettlement(
    int groupId,
    CreateSettlementRequest request,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(settlementRepositoryProvider);

      return repository.createSettlement(groupId, request);
    });
  }
}
