import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill_frontend/features/groups/data/models/user_search_result.dart';
import 'package:splitbill_frontend/features/groups/presentation/providers/group_provider.dart';

final userSearchProvider =
    FutureProvider.family<List<UserSearchResult>, String>((ref, query) async {
      final repository = ref.read(groupRepositoryProvider);

      if (query.trim().length < 2) {
        return [];
      }

      return repository.searchUsers(query.trim());
    });
