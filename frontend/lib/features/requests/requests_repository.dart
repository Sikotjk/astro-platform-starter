import 'package:dio/dio.dart';

import '../../models/package_request.dart';

/// Zugriff auf das Wunsch-Board (umgekehrter Marktplatz).
abstract class RequestsRepository {
  /// Öffentliches Board, optional nach Route gefiltert.
  Future<List<PackageRequest>> search({
    String? originAirport,
    String? destinationAirport,
  });

  /// Eigene Wünsche des angemeldeten Senders.
  Future<List<PackageRequest>> listMine();

  /// Einzelnen Wunsch laden.
  Future<PackageRequest> findOne(String id);

  /// Neuen Wunsch veröffentlichen (erfordert Anmeldung).
  Future<PackageRequest> create(CreateRequestInput input);
}

class DioRequestsRepository implements RequestsRepository {
  DioRequestsRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<PackageRequest>> search({
    String? originAirport,
    String? destinationAirport,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/requests',
      queryParameters: {
        if (originAirport != null && originAirport.isNotEmpty)
          'originAirport': originAirport.toUpperCase(),
        if (destinationAirport != null && destinationAirport.isNotEmpty)
          'destinationAirport': destinationAirport.toUpperCase(),
      },
    );
    return (res.data ?? [])
        .map((e) => PackageRequest.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<PackageRequest>> listMine() async {
    final res = await _dio.get<List<dynamic>>('/requests/mine');
    return (res.data ?? [])
        .map((e) => PackageRequest.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<PackageRequest> findOne(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/requests/$id');
    return PackageRequest.fromJson(res.data!);
  }

  @override
  Future<PackageRequest> create(CreateRequestInput input) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/requests',
      data: input.toJson(),
    );
    return PackageRequest.fromJson(res.data!);
  }
}
