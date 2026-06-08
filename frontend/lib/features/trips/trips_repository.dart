import 'package:dio/dio.dart';

import '../../models/trip.dart';

abstract class TripsRepository {
  Future<List<Trip>> search(TripSearchQuery query);
}

class DioTripsRepository implements TripsRepository {
  DioTripsRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Trip>> search(TripSearchQuery query) async {
    final res = await _dio.get<List<dynamic>>(
      '/trips',
      queryParameters: query.toQuery(),
    );
    return (res.data ?? [])
        .map((e) => Trip.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
