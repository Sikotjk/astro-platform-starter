import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/api_client.dart';
import 'package:tj_shipping_app/core/token_store.dart';

/// Stub-Adapter, der einen festen Statuscode zurückgibt, ohne Netzwerk.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode);
  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"message":"x"}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('401-Antwort löst onUnauthorized aus', () async {
    var triggered = 0;
    final client = ApiClient.create(
      InMemoryTokenStore()..write('tok'),
      baseUrl: 'http://example.test',
      onUnauthorized: () => triggered++,
    );
    client.dio.httpClientAdapter = _StubAdapter(401);

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
    client.dio.httpClientAdapter = _StubAdapter(200);

    await client.dio.get<dynamic>('/me');
    expect(triggered, 0);
  });
}
