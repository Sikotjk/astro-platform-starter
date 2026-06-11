import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'demo_backend.dart';

/// Dio-`HttpClientAdapter`, der alle Anfragen an das In-Memory-[DemoBackend]
/// umleitet — so läuft die App im Demo-Modus ohne echten Server, ohne dass
/// Repositories, Controller oder Screens etwas davon mitbekommen.
class DemoHttpAdapter implements HttpClientAdapter {
  DemoHttpAdapter([DemoBackend? backend]) : _backend = backend ?? DemoBackend();

  final DemoBackend _backend;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = await _readJsonBody(requestStream);
    final query = options.uri.queryParameters;

    // Leichte Latenz, damit Ladezustände (Spinner) im Demo sichtbar sind.
    await Future<void>.delayed(const Duration(milliseconds: 180));

    final res = _backend.handle(options.method, options.uri.path, query, body);

    if (res.bytes != null) {
      return ResponseBody.fromBytes(
        res.bytes!,
        res.statusCode,
        headers: {
          Headers.contentTypeHeader: [
            res.contentType ?? 'application/octet-stream',
          ],
        },
      );
    }
    return ResponseBody.fromString(
      jsonEncode(res.body),
      res.statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  /// Liest den (evtl. vorhandenen) JSON-Request-Body aus dem Stream.
  Future<Map<String, dynamic>?> _readJsonBody(Stream<Uint8List>? stream) async {
    if (stream == null) return null;
    final chunks = await stream.toList();
    if (chunks.isEmpty) return null;
    final bytes = chunks.expand((c) => c).toList();
    if (bytes.isEmpty) return null;
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  @override
  void close({bool force = false}) {}
}
