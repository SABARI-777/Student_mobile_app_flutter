
import 'package:dio/dio.dart';

class AuthRepository {
  final Dio dio;

  AuthRepository(this.dio);

  // Login to Frappe
  Future<String> login(
    String username,
    String password,
  ) async {
    final response = await dio.post(
      '/api/method/login',
      data: {
        'usr': username,
        'pwd': password,
      },
    );

    return response.data['full_name']?.toString()
        ?? 'Logged in';
  }

  // Check the currently logged-in user
  Future<String> getLoggedUser() async {
    final response = await dio.get(
      '/api/method/frappe.auth.get_logged_user',
    );

    return response.data['message'].toString();
  }

  // Logout from Frappe
  Future<void> logout() async {
    await dio.post('/api/method/logout');
  }
}
