import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill_frontend/app/core/errors/api_exception.dart';

import '../../data/models/user.dart';
import '../providers/auth_provider.dart';

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final storage = ref.read(secureStorageProvider);

    final token = await storage.getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final repository = ref.read(authRepositoryProvider);

      return await repository.getProfile();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await storage.deleteToken();
        return null;
      }

      rethrow;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageProvider);

      final response = await repository.login(email: email, password: password);

      await storage.saveToken(response.token);

      return User(id: response.id, name: response.name, email: response.email);
    });
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);

    await storage.deleteToken();

    state = const AsyncData(null);
  }
}
