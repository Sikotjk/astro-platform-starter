import 'package:flutter/material.dart';

/// Verkürzte Buchung aus GET /bookings (Listenansicht).
class BookingSummary {
  const BookingSummary({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.currency,
    required this.senderId,
    required this.travelerId,
    required this.packageTitle,
    required this.originAirport,
    required this.destinationAirport,
    required this.departureAt,
  });

  final String id;
  final String status;
  final String paymentStatus;
  final double totalAmount;
  final String currency;
  final String senderId;
  final String travelerId;
  final String packageTitle;
  final String originAirport;
  final String destinationAirport;
  final DateTime departureAt;

  String get route => '$originAirport → $destinationAirport';

  factory BookingSummary.fromJson(Map<String, dynamic> json) {
    final pkg = json['package'] as Map<String, dynamic>?;
    final trip = json['trip'] as Map<String, dynamic>?;
    return BookingSummary(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'REQUESTED',
      paymentStatus: json['paymentStatus'] as String? ?? 'PENDING',
      totalAmount: double.tryParse(json['totalAmount'].toString()) ?? 0,
      currency: json['currency'] as String? ?? 'EUR',
      senderId: json['senderId'] as String? ?? '',
      travelerId: json['travelerId'] as String? ?? '',
      packageTitle: pkg?['title'] as String? ?? '—',
      originAirport: trip?['originAirport'] as String? ?? '???',
      destinationAirport: trip?['destinationAirport'] as String? ?? '???',
      departureAt: trip?['departureAt'] != null
          ? DateTime.parse(trip!['departureAt'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Farbe je Buchungsstatus (für UI-Chips). Die Beschriftung kommt aus l10n.
Color bookingStatusColor(String status) {
  return switch (status) {
    'REQUESTED' => Colors.blueGrey,
    'ACCEPTED' => Colors.indigo,
    'PAID' => Colors.teal,
    'HANDED_OVER' => Colors.purple,
    'IN_TRANSIT' => Colors.orange,
    'DELIVERED' => Colors.lightGreen,
    'CONFIRMED' => Colors.green,
    'DISPUTED' => Colors.red,
    'REFUNDED' => Colors.brown,
    'CANCELLED' => Colors.grey,
    'REJECTED' => Colors.grey,
    _ => Colors.grey,
  };
}

/// Icon je Zahlungsstatus (für UI). Beschriftung kommt aus l10n.
IconData paymentStatusIcon(String paymentStatus) {
  return switch (paymentStatus) {
    'ESCROW_HELD' => Icons.lock_outline,
    'RELEASED' => Icons.check_circle_outline,
    'REFUNDED' => Icons.undo,
    'FAILED' => Icons.error_outline,
    _ => Icons.schedule, // PENDING
  };
}
