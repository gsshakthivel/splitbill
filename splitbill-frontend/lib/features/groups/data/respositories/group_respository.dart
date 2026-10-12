import 'package:splitbill_frontend/app/core/network/api_client.dart';
import 'package:splitbill_frontend/features/groups/data/models/add_member_response.dart';
import 'package:splitbill_frontend/features/groups/data/models/balance.dart';
import 'package:splitbill_frontend/features/groups/data/models/create_group_request.dart';
import 'package:splitbill_frontend/features/groups/data/models/group.dart';
import 'package:splitbill_frontend/features/groups/data/models/group_details.dart';
import 'package:splitbill_frontend/features/groups/data/models/user_search_result.dart';

class GroupRepository {
  GroupRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Group>> getGroups() async {
    final response = await _apiClient.get<List<dynamic>>('/groups');

    return response.data!
        .map((json) => Group.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<GroupDetails> getGroupDetails(int groupId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/groups/$groupId',
    );

    return GroupDetails.fromJson(response.data!);
  }

  Future<List<Balance>> getBalances(int groupId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/groups/$groupId/balances',
    );

    final data = response.data!['data'] as List<dynamic>;

    return data
        .map((json) => Balance.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Group> createGroup(CreateGroupRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/groups',
      data: request.toJson(),
    );

    return Group.fromJson(response.data!);
  }

  Future<List<UserSearchResult>> searchUsers(String query) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/auth/users/search',
      queryParameters: {'q': query},
    );

    final users = response.data!['users'] as List<dynamic>;

    return users
        .map((json) => UserSearchResult.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<AddMemberResponse> addMember({
    required int groupId,
    required int userId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/groups/$groupId/members',
      data: {'userId': userId},
    );

    return AddMemberResponse.fromJson(response.data!);
  }

  Future<void> removeMember({required int groupId, required int userId}) async {
    await _apiClient.delete('/groups/$groupId/members/$userId');
  }
}
