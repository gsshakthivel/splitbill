import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/create_group_request.dart';
import '../providers/group_provider.dart';

final groupNotifierProvider = AsyncNotifierProvider<GroupNotifier, void>(
  GroupNotifier.new,
);

class GroupNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createGroup(CreateGroupRequest request) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(groupRepositoryProvider);

      await repository.createGroup(request);
    });
  }

  Future<void> addMember({required int groupId, required int userId}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(groupRepositoryProvider);

      await repository.addMember(groupId: groupId, userId: userId);
    });
  }

  Future<void> removeMember({required int groupId, required int userId}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(groupRepositoryProvider);

      await repository.removeMember(groupId: groupId, userId: userId);
    });
  }
}
