import 'package:dio/dio.dart';

import '../../models/booking.dart';

abstract class BookingsRepository {
  Future<List<BookingSummary>> list({String? role, String? status});
}

class DioBookingsRepository implements BookingsRepository {
  DioBookingsRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<BookingSummary>> list({String? role, String? status}) async {
    final query = <String, dynamic>{};
    if (role != null) query['role'] = role;
    if (status != null && status.isNotEmpty) query['status'] = status;

    final res = await _dio.get<List<dynamic>>(
      '/bookings',
      queryParameters: query,
    );
    return (res.data ?? [])
        .map((e) => BookingSummary.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
