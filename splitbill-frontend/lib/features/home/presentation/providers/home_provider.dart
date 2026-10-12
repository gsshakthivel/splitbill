import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../groups/data/models/group.dart';
import '../notifiers/home_notifier.dart';

final homeNotifierProvider = AsyncNotifierProvider<HomeNotifier, List<Group>>(
  HomeNotifier.new,
);
