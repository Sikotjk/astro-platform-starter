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

  /// Als Reisender ein Angebot auf einen Wunsch abgeben.
  Future<RequestOffer> createOffer(String requestId, {String? message});

  /// Angebote eines Wunsches (nur der Ersteller darf sie sehen).
  Future<List<RequestOffer>> listOffers(String requestId);

  /// Als Ersteller ein Angebot annehmen (Wunsch wird MATCHED).
  Future<RequestOffer> acceptOffer(String requestId, String offerId);
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

  @override
  Future<RequestOffer> createOffer(String requestId, {String? message}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/requests/$requestId/offers',
      data: {if (message != null && message.isNotEmpty) 'message': message},
    );
    return RequestOffer.fromJson(res.data!);
  }

  @override
  Future<List<RequestOffer>> listOffers(String requestId) async {
    final res = await _dio.get<List<dynamic>>('/requests/$requestId/offers');
    return (res.data ?? [])
        .map((e) => RequestOffer.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<RequestOffer> acceptOffer(String requestId, String offerId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/requests/$requestId/offers/$offerId/accept',
    );
    return RequestOffer.fromJson(res.data!);
  }
}
