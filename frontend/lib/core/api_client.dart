import 'package:dio/dio.dart';

import 'config.dart';
import 'token_store.dart';

/// Dünner Wrapper um Dio: setzt die Basis-URL, hängt das Bearer-Token an und
/// erneuert bei 401 automatisch die Session über das Refresh-Token (Rotation).
class ApiClient {
  ApiClient(this.dio);

  final Dio dio;

  factory ApiClient.create(
    TokenStore tokenStore, {
    String? baseUrl,
    void Function()? onUnauthorized,
    HttpClientAdapter? adapter,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    // Demo-Modus: Anfragen gehen an ein In-Memory-Backend statt ins Netz.
    if (adapter != null) dio.httpClientAdapter = adapter;

    // Single-Flight: parallele 401s teilen sich EINEN Refresh-Aufruf.
    Future<String?>? refreshing;

    Future<String?> refreshAccessToken() async {
      final refresh = await tokenStore.readRefresh();
      if (refresh == null || refresh.isEmpty) return null;
      try {
        // Läuft über dasselbe Dio; /auth/* ist vom Retry-Pfad ausgenommen,
        // daher keine Endlosschleife.
        final res = await dio.post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refreshToken': refresh},
        );
        final access = res.data!['accessToken'] as String;
        final newRefresh = res.data!['refreshToken'] as String;
        await tokenStore.write(access);
        await tokenStore.writeRefresh(newRefresh);
        return access;
      } catch (_) {
        return null; // ungültig/abgelaufen -> Session beenden
      }
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStore.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          final isAuthRoute = e.requestOptions.path.contains('/auth/');
          if (e.response?.statusCode != 401 || isAuthRoute) {
            handler.next(e);
            return;
          }

          // Access-Token abgelaufen: einmal erneuern, Request wiederholen.
          refreshing ??= refreshAccessToken();
          final newToken = await refreshing;
          refreshing = null;

          if (newToken == null) {
            onUnauthorized?.call();
            handler.next(e);
            return;
          }
          try {
            final opts = e.requestOptions
              ..headers['Authorization'] = 'Bearer $newToken';
            handler.resolve(await dio.fetch<dynamic>(opts));
          } on DioException catch (retryErr) {
            handler.next(retryErr);
          }
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
