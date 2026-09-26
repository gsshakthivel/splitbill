import 'package:splitbill_frontend/app/core/network/api_client.dart';
import 'package:splitbill_frontend/features/auth/data/models/auth_response.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
      requiresAuth: false,
    );

    return AuthResponse.fromJson(response.data!);
  }
}
