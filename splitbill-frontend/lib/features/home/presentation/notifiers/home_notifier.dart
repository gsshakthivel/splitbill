import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill_frontend/features/groups/data/models/group_details.dart';

import '../../../groups/data/models/group.dart';
import '../../../groups/presentation/providers/group_provider.dart';

class HomeNotifier extends AsyncNotifier<List<Group>> {
  @override
  Future<List<Group>> build() async {
    final repository = ref.read(groupRepositoryProvider);

    return repository.getGroups();
  }

  Future<void> refreshGroups() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(groupRepositoryProvider);

      final groups = await repository.getGroups();

      return groups;
    });
  }

  Future<GroupDetails> getGroupDetails(int groupId) async {
    final repository = ref.read(groupRepositoryProvider);

    return repository.getGroupDetails(groupId);
  }
}
