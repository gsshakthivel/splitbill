import 'package:splitbill_frontend/app/core/network/api_client.dart';
import 'package:splitbill_frontend/features/home/data/models/group.dart';

class HomeRepository {
  HomeRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Group>> getGroups() async {
    final response = await _apiClient.get<List<dynamic>>('/groups');

    return response.data!
        .map((json) => Group.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
