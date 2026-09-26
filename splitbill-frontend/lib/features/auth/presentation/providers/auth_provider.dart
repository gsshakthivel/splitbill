import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill_frontend/app/core/network/api_client.dart';
import 'package:splitbill_frontend/app/core/storage/secure_storage_service.dart';
import 'package:splitbill_frontend/features/auth/data/models/auth_response.dart';

import '../notifiers/auth_notifier.dart';
import '../../data/repositories/auth_repository.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);

  return ApiClient(storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return AuthRepository(apiClient);
});

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthResponse?>(
  AuthNotifier.new,
);
