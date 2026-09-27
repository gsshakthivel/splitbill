import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill_frontend/features/auth/presentation/providers/auth_provider.dart';

import '../../data/models/group.dart';
import '../../data/repositories/home_repository.dart';
import '../notifiers/home_notifier.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return HomeRepository(apiClient);
});

final homeNotifierProvider = AsyncNotifierProvider<HomeNotifier, List<Group>>(
  HomeNotifier.new,
);
