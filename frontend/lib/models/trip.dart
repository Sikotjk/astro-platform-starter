/// Reisender (verkürzt) wie ihn die Trip-Suche mitliefert.
class TripTraveler {
  const TripTraveler({
    required this.firstName,
    required this.ratingAvg,
    required this.ratingCount,
    this.id,
  });

  final String firstName;
  final double ratingAvg;
  final int ratingCount;
  final String? id;

  factory TripTraveler.fromJson(Map<String, dynamic> json) {
    return TripTraveler(
      firstName: json['firstName'] as String? ?? '',
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      id: json['id'] as String?,
    );
  }
}

/// Ein Trip-Angebot aus GET /trips.
class Trip {
  const Trip({
    required this.id,
    required this.originAirport,
    required this.destinationAirport,
    required this.departureAt,
    required this.freeKg,
    required this.pricePerKg,
    required this.currency,
    this.departureGate,
    this.traveler,
    this.status,
  });

  final String id;
  final String originAirport;
  final String destinationAirport;
  final DateTime departureAt;
  final double freeKg;
  final double pricePerKg;
  final String currency;
  final String? departureGate;
  final TripTraveler? traveler;

  /// Trip-Status (z.B. ACTIVE/FULL/CANCELLED) — gesetzt bei „Meine Trips".
  final String? status;

  /// "FRA → DYU"
  String get route => '$originAirport → $destinationAirport';

  /// Abflugdatum als "YYYY-MM-DD".
  String get departureDate {
    final d = departureAt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      originAirport: json['originAirport'] as String,
      destinationAirport: json['destinationAirport'] as String,
      departureAt: DateTime.parse(json['departureAt'] as String),
      freeKg: (json['freeKg'] as num?)?.toDouble() ?? 0,
      pricePerKg: double.tryParse(json['pricePerKg'].toString()) ?? 0,
      currency: json['currency'] as String? ?? 'EUR',
      departureGate: json['departureGate'] as String?,
      traveler: json['traveler'] is Map<String, dynamic>
          ? TripTraveler.fromJson(json['traveler'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String?,
    );
  }
}

/// Suchparameter für die Trip-Suche.
class TripSearchQuery {
  const TripSearchQuery({
    this.originAirport,
    this.destinationAirport,
    this.minFreeKg,
  });

  final String? originAirport;
  final String? destinationAirport;
  final double? minFreeKg;

  Map<String, dynamic> toQuery() {
    return {
      if (originAirport != null && originAirport!.isNotEmpty)
        'originAirport': originAirport!.toUpperCase(),
      if (destinationAirport != null && destinationAirport!.isNotEmpty)
        'destinationAirport': destinationAirport!.toUpperCase(),
      if (minFreeKg != null) 'minFreeKg': minFreeKg,
    };
  }
}
