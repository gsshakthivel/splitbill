import 'package:splitbill_frontend/app/core/network/api_client.dart';

import '../models/create_settlement_request.dart';
import '../models/settlement.dart';

class SettlementRepository {
  SettlementRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Settlement> createSettlement(
    int groupId,
    CreateSettlementRequest request,
  ) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/groups/$groupId/settlements',
      data: request.toJson(),
    );

    final data = response.data!['data'] as Map<String, dynamic>;

    return Settlement.fromCreateJson(data);
  }

  Future<List<Settlement>> getSettlements(int groupId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/groups/$groupId/settlements',
    );

    final data = response.data!['data'] as List<dynamic>;

    return data
        .map((json) => Settlement.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
