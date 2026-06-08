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

/// Deutsche Beschriftung + Farbe je Buchungsstatus (für UI-Chips).
({String label, Color color}) bookingStatusStyle(String status) {
  return switch (status) {
    'REQUESTED' => (label: 'Angefragt', color: Colors.blueGrey),
    'ACCEPTED' => (label: 'Akzeptiert', color: Colors.indigo),
    'PAID' => (label: 'Bezahlt', color: Colors.teal),
    'HANDED_OVER' => (label: 'Übergeben', color: Colors.purple),
    'IN_TRANSIT' => (label: 'Im Transit', color: Colors.orange),
    'DELIVERED' => (label: 'Zugestellt', color: Colors.lightGreen),
    'CONFIRMED' => (label: 'Abgeschlossen', color: Colors.green),
    'DISPUTED' => (label: 'Streitfall', color: Colors.red),
    'REFUNDED' => (label: 'Erstattet', color: Colors.brown),
    'CANCELLED' => (label: 'Storniert', color: Colors.grey),
    'REJECTED' => (label: 'Abgelehnt', color: Colors.grey),
    _ => (label: status, color: Colors.grey),
  };
}
