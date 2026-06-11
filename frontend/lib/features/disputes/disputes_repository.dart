import 'package:dio/dio.dart';

abstract class DisputesRepository {
  /// Eröffnet einen Streitfall zu einer Buchung (POST /bookings/:id/dispute).
  /// Wirft, wenn im aktuellen Status nicht erlaubt (Backend: 409).
  Future<void> open(String bookingId, String reason);
}

class DioDisputesRepository implements DisputesRepository {
  DioDisputesRepository(this._dio);

  final Dio _dio;

  @override
  Future<void> open(String bookingId, String reason) async {
    await _dio.post<void>(
      '/bookings/$bookingId/dispute',
      data: {'reason': reason},
    );
  }
}
