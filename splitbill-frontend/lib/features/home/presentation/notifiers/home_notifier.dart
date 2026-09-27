import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/group.dart';
import '../providers/home_provider.dart';

class HomeNotifier extends AsyncNotifier<List<Group>> {
  @override
  Future<List<Group>> build() async {
    final repository = ref.read(homeRepositoryProvider);

    return repository.getGroups();
  }

  Future<void> refreshGroups() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(homeRepositoryProvider);

      return repository.getGroups();
    });
  }
}
