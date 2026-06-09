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

/// Öffentliche Profildaten einer Buchungspartei (Name + Reputation).
class BookingParty {
  const BookingParty({
    required this.id,
    required this.firstName,
    required this.ratingAvg,
    required this.ratingCount,
  });

  final String id;
  final String firstName;
  final double ratingAvg;
  final int ratingCount;

  factory BookingParty.fromJson(Map<String, dynamic> json) {
    return BookingParty(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0,
      ratingCount: json['ratingCount'] as int? ?? 0,
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
    this.sender,
    this.traveler,
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
  final BookingParty? sender;
  final BookingParty? traveler;

  /// Die jeweils andere Partei aus Sicht von [myId].
  BookingParty? counterparty(String? myId) {
    if (myId == senderId) return traveler;
    if (myId == travelerId) return sender;
    return null;
  }

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    final pkg = json['package'] as Map<String, dynamic>?;
    final events = (json['statusEvents'] as List<dynamic>? ?? [])
        .map((e) => BookingStatusEvent.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    BookingParty? party(String key) {
      final raw = json[key];
      return raw is Map<String, dynamic> ? BookingParty.fromJson(raw) : null;
    }

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
      sender: party('sender'),
      traveler: party('traveler'),
    );
  }
}
