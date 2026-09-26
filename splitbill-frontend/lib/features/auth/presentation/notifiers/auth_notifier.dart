import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/auth_response.dart';
import '../providers/auth_provider.dart';

class AuthNotifier extends AsyncNotifier<AuthResponse?> {
  @override
  Future<AuthResponse?> build() async {
    final storage = ref.read(secureStorageProvider);

    final token = await storage.getToken();

    if (token == null) {
      return null;
    }

    // We have a token, but we don't have the full user yet.
    // We'll handle token validation/user restoration next.
    return null;
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageProvider);

      final response = await repository.login(email: email, password: password);

      await storage.saveToken(response.token);

      return response;
    });
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);

    await storage.deleteToken();

    state = const AsyncData(null);
  }
}
