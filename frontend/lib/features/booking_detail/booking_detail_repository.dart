import 'package:dio/dio.dart';

import '../../models/booking_detail.dart';

abstract class BookingDetailRepository {
  /// Lädt die Detailsicht inkl. Status-Verlauf (GET /bookings/:id).
  Future<BookingDetail> fetch(String id);

  /// Löst einen Status-Übergang aus (`POST /bookings/:id/<path>`).
  Future<void> act(String id, String path);

  /// Erzeugt den Stripe-PaymentIntent und liefert dessen clientSecret zurück
  /// (`POST /bookings/:id/escrow`).
  Future<String> createEscrow(String id);
}

class DioBookingDetailRepository implements BookingDetailRepository {
  DioBookingDetailRepository(this._dio);

  final Dio _dio;

  @override
  Future<BookingDetail> fetch(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/bookings/$id');
    return BookingDetail.fromJson(res.data ?? const {});
  }

  @override
  Future<void> act(String id, String path) async {
    await _dio.post<void>('/bookings/$id/$path');
  }

  @override
  Future<String> createEscrow(String id) async {
    final res = await _dio.post<Map<String, dynamic>>('/bookings/$id/escrow');
    return res.data!['clientSecret'] as String;
  }
}
