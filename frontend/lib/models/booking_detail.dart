/// Ein Eintrag im append-only Status-Audit-Log einer Buchung.
class BookingStatusEvent {
  const BookingStatusEvent({
    required this.toStatus,
    required this.triggeredBy,
    required this.createdAt,
  });

  final String toStatus;
  final String triggeredBy;
  final DateTime createdAt;

  factory BookingStatusEvent.fromJson(Map<String, dynamic> json) {
    return BookingStatusEvent(
      toStatus: json['toStatus'] as String? ?? '',
      triggeredBy: json['triggeredBy'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

/// Detailsicht einer Buchung (GET /bookings/:id).
class BookingDetail {
  const BookingDetail({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.currency,
    required this.senderId,
    required this.travelerId,
    required this.packageTitle,
    required this.termsAccepted,
    required this.events,
  });

  final String id;
  final String status;
  final String paymentStatus;
  final double totalAmount;
  final String currency;
  final String senderId;
  final String travelerId;
  final String packageTitle;
  final bool termsAccepted;
  final List<BookingStatusEvent> events;

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    final pkg = json['package'] as Map<String, dynamic>?;
    final events = (json['statusEvents'] as List<dynamic>? ?? [])
        .map((e) => BookingStatusEvent.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    return BookingDetail(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'REQUESTED',
      paymentStatus: json['paymentStatus'] as String? ?? 'PENDING',
      totalAmount: double.tryParse(json['totalAmount'].toString()) ?? 0,
      currency: json['currency'] as String? ?? 'EUR',
      senderId: json['senderId'] as String? ?? '',
      travelerId: json['travelerId'] as String? ?? '',
      packageTitle: pkg?['title'] as String? ?? '—',
      termsAccepted: json['travelerAcceptedTermsAt'] != null,
      events: events,
    );
  }
}
