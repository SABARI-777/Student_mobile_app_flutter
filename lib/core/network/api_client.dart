import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    final cookieJar = CookieJar();

    dio = Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:8000',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Host': 'pilot.localhost:8000',
        },
      ),
    );

    dio.interceptors.add(CookieManager(cookieJar));
  }
}