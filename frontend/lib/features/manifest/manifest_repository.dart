import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Geladenes Zoll-Manifest (PDF-Bytes + Integritäts-Hash aus dem Header).
/// [fromCache] kennzeichnet eine lokal gespeicherte Offline-Kopie.
class ManifestPdf {
  const ManifestPdf({required this.bytes, this.hash, this.fromCache = false});

  final Uint8List bytes;
  final String? hash;
  final bool fromCache;

  int get sizeKb => (bytes.lengthInBytes / 1024).ceil();
}

abstract class ManifestRepository {
  /// Lädt das Manifest-PDF einer Buchung in der gewünschten Sprache.
  /// Wirft, wenn es noch nicht verfügbar ist (Backend antwortet mit 409).
  Future<ManifestPdf> fetch(String bookingId, {String locale});
}

class DioManifestRepository implements ManifestRepository {
  DioManifestRepository(this._dio);

  final Dio _dio;

  @override
  Future<ManifestPdf> fetch(String bookingId, {String locale = 'de'}) async {
    final res = await _dio.get<List<int>>(
      '/bookings/$bookingId/manifest',
      queryParameters: {'locale': locale},
      options: Options(responseType: ResponseType.bytes),
    );
    return ManifestPdf(
      bytes: Uint8List.fromList(res.data ?? const []),
      hash: res.headers.value('x-manifest-hash'),
    );
  }
}
