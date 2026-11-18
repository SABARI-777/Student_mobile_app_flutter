
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/storage/preferences_service.dart';
import '../repositories/auth_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient.dio);
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

final authProvider =
    AsyncNotifierProvider<AuthNotifier, String?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<String?> {
  static const String offlineUserKey = 'offline_user';

  @override
  Future<String?> build() async {
    final storage = ref.read(preferencesServiceProvider);
    final repository = ref.read(authRepositoryProvider);

    // Read the locally saved user.
    final savedUser = await storage.getString(offlineUserKey);

    if (savedUser == null || savedUser.isEmpty) {
      return null;
    }

    try {
      // Verify the actual Frappe session.
      final loggedUser = await repository.getLoggedUser();

      if (loggedUser.isEmpty ||
          loggedUser.toLowerCase() == 'guest') {
        await storage.remove(offlineUserKey);
        return null;
      }

      // Valid Frappe session.
      await storage.saveString(offlineUserKey, loggedUser);
      return loggedUser;

    } on DioException catch (error) {
      // No server response usually means the server is
      // unreachable or the phone is offline.
      if (error.response == null) {
        return savedUser;
      }

      // Server responded but rejected authentication.
      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 403) {
        await storage.remove(offlineUserKey);
        return null;
      }

      rethrow;
    }
  }

  Future<void> login(
    String username,
    String password,
  ) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final storage = ref.read(preferencesServiceProvider);

      // Authenticate with Frappe.
      await repository.login(username, password);

      // Verify the authenticated Frappe user.
      final loggedUser = await repository.getLoggedUser();

      if (loggedUser.isEmpty ||
          loggedUser.toLowerCase() == 'guest') {
        throw Exception('Frappe login was not successful');
      }

      await storage.saveString(offlineUserKey, loggedUser);

      state = AsyncData(loggedUser);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    final storage = ref.read(preferencesServiceProvider);

    try {
      await repository.logout();
    } catch (_) {
      // Server may be unavailable.
    } finally {
      await storage.remove(offlineUserKey);
      state = const AsyncData(null);
    }
  }
}
