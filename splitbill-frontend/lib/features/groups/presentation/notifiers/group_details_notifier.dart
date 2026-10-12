import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/group_details.dart';
import '../providers/group_provider.dart';

final groupDetailsProvider = FutureProvider.family<GroupDetails, int>((
  ref,
  groupId,
) async {
  final repository = ref.read(groupRepositoryProvider);

  return repository.getGroupDetails(groupId);
});
