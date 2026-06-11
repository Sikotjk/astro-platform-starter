import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/api_client.dart';
import 'package:tj_shipping_app/core/token_store.dart';

/// Stub-Adapter, der Anfragen per Callback beantwortet (ohne Netzwerk).
class _RoutingAdapter implements HttpClientAdapter {
  _RoutingAdapter(this.handler);
  final ResponseBody Function(RequestOptions options) handler;
  final List<String> calls = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options.path);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Map<String, dynamic> body) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

void main() {
  test('401 ohne Refresh-Token löst onUnauthorized aus', () async {
    var triggered = 0;
    final client = ApiClient.create(
      InMemoryTokenStore()..write('tok'),
      baseUrl: 'http://example.test',
      onUnauthorized: () => triggered++,
    );
    client.dio.httpClientAdapter = _RoutingAdapter(
      (_) => _json(401, {'message': 'x'}),
    );

    await expectLater(
      client.dio.get<dynamic>('/me'),
      throwsA(isA<DioException>()),
    );
    expect(triggered, 1);
  });

  test('Erfolgs-Antwort löst onUnauthorized NICHT aus', () async {
    var triggered = 0;
    final client = ApiClient.create(
      InMemoryTokenStore()..write('tok'),
      baseUrl: 'http://example.test',
      onUnauthorized: () => triggered++,
    );
    client.dio.httpClientAdapter = _RoutingAdapter((_) => _json(200, {}));

    await client.dio.get<dynamic>('/me');
    expect(triggered, 0);
  });

  test(
    '401 mit Refresh-Token: erneuert Session und wiederholt den Request',
    () async {
      var triggered = 0;
      final store = InMemoryTokenStore()
        ..write('tok_old')
        ..writeRefresh('refresh_old');
      final client = ApiClient.create(
        store,
        baseUrl: 'http://example.test',
        onUnauthorized: () => triggered++,
      );

      final adapter = _RoutingAdapter((options) {
        if (options.path == '/auth/refresh') {
          return _json(200, {
            'accessToken': 'tok_new',
            'refreshToken': 'refresh_new',
            'userId': 'u1',
          });
        }
        // /me: mit altem Token 401, mit neuem 200.
        final auth = options.headers['Authorization'] as String?;
        return auth == 'Bearer tok_new'
            ? _json(200, {'id': 'u1'})
            : _json(401, {'message': 'expired'});
      });
      client.dio.httpClientAdapter = adapter;

      final res = await client.dio.get<Map<String, dynamic>>('/me');

      expect(res.statusCode, 200);
      expect(res.data!['id'], 'u1');
      expect(await store.read(), 'tok_new');
      expect(await store.readRefresh(), 'refresh_new'); // rotiert
      expect(triggered, 0);
      expect(adapter.calls, ['/me', '/auth/refresh', '/me']);
    },
  );

  test('Refresh schlägt fehl -> onUnauthorized (Session-Ende)', () async {
    var triggered = 0;
    final store = InMemoryTokenStore()
      ..write('tok_old')
      ..writeRefresh('refresh_dead');
    final client = ApiClient.create(
      store,
      baseUrl: 'http://example.test',
      onUnauthorized: () => triggered++,
    );
    client.dio.httpClientAdapter = _RoutingAdapter(
      (options) => _json(401, {'message': 'nope'}),
    );

    await expectLater(
      client.dio.get<dynamic>('/me'),
      throwsA(isA<DioException>()),
    );
    expect(triggered, 1);
  });
}
