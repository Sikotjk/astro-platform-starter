import 'package:dio/dio.dart';

import 'config.dart';
import 'token_store.dart';

/// Dünner Wrapper um Dio: setzt die Basis-URL und hängt automatisch das
/// Bearer-Token aus dem TokenStore an jede Anfrage.
class ApiClient {
  ApiClient(this.dio);

  final Dio dio;

  factory ApiClient.create(
    TokenStore tokenStore, {
    String? baseUrl,
    void Function()? onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStore.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          // Abgelaufene/ungültige Session -> Logout-Hook auslösen.
          if (e.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          handler.next(e);
        },
      ),
    );

    return ApiClient(dio);
  }
}

/// Übersetzt Dio-Fehler in eine nutzerfreundliche Nachricht.
String apiErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      final msg = data['message'];
      return msg is List ? msg.join(', ') : msg.toString();
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Keine Verbindung zum Server.';
    }
  }
  return 'Es ist ein Fehler aufgetreten.';
}
