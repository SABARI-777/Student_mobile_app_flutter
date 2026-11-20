
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../repositories/auth_repository.dart';

// One API client for the application session
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Authentication repository
final authRepositoryProvider =
    Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return AuthRepository(apiClient.dio);
});
