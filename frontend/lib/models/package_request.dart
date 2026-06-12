/// Sender (verkürzt), wie ihn das Wunsch-Board mitliefert.
class RequestSender {
  const RequestSender({
    required this.firstName,
    required this.ratingAvg,
    required this.ratingCount,
    this.id,
    this.kycVerified = false,
  });

  final String firstName;
  final double ratingAvg;
  final int ratingCount;
  final String? id;
  final bool kycVerified;

  factory RequestSender.fromJson(Map<String, dynamic> json) {
    return RequestSender(
      firstName: json['firstName'] as String? ?? '',
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      id: json['id'] as String?,
      kycVerified: json['kycStatus'] == 'VERIFIED',
    );
  }
}

/// Ein Liefer-Wunsch vom Board (GET /requests).
class PackageRequest {
  const PackageRequest({
    required this.id,
    required this.title,
    required this.originAirport,
    required this.destinationAirport,
    required this.weightKg,
    required this.rewardOffered,
    required this.currency,
    required this.category,
    required this.status,
    this.desiredByDate,
    this.notes,
    this.sender,
    this.createdAt,
  });

  final String id;
  final String title;
  final String originAirport;
  final String destinationAirport;
  final double weightKg;
  final double rewardOffered;
  final String currency;
  final String category;
  final String status;
  final DateTime? desiredByDate;
  final String? notes;
  final RequestSender? sender;
  final DateTime? createdAt;

  String get route => '$originAirport → $destinationAirport';

  factory PackageRequest.fromJson(Map<String, dynamic> json) {
    return PackageRequest(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      originAirport: json['originAirport'] as String? ?? '???',
      destinationAirport: json['destinationAirport'] as String? ?? '???',
      weightKg: double.tryParse('${json['weightKg']}') ?? 0,
      rewardOffered: double.tryParse('${json['rewardOffered']}') ?? 0,
      currency: json['currency'] as String? ?? 'EUR',
      category: json['category'] as String? ?? 'OTHER',
      status: json['status'] as String? ?? 'OPEN',
      desiredByDate: json['desiredByDate'] != null
          ? DateTime.tryParse(json['desiredByDate'] as String)
          : null,
      notes: json['notes'] as String?,
      sender: json['sender'] is Map<String, dynamic>
          ? RequestSender.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

/// Angebot eines Reisenden auf einen Wunsch (GET /requests/:id/offers).
class RequestOffer {
  const RequestOffer({
    required this.id,
    required this.status,
    this.message,
    this.traveler,
    this.createdAt,
  });

  final String id;
  final String status; // PENDING | ACCEPTED | DECLINED
  final String? message;
  final RequestSender? traveler;
  final DateTime? createdAt;

  bool get isAccepted => status == 'ACCEPTED';
  bool get isDeclined => status == 'DECLINED';

  factory RequestOffer.fromJson(Map<String, dynamic> json) {
    return RequestOffer(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'PENDING',
      message: json['message'] as String?,
      traveler: json['traveler'] is Map<String, dynamic>
          ? RequestSender.fromJson(json['traveler'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

/// Eingaben zum Erstellen eines Wunsches (POST /requests).
class CreateRequestInput {
  const CreateRequestInput({
    required this.title,
    required this.originAirport,
    required this.destinationAirport,
    required this.weightKg,
    required this.rewardOffered,
    required this.category,
    this.desiredByDate,
    this.notes,
  });

  final String title;
  final String originAirport;
  final String destinationAirport;
  final double weightKg;
  final double rewardOffered;
  final String category;
  final DateTime? desiredByDate;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'title': title,
    'originAirport': originAirport.toUpperCase(),
    'destinationAirport': destinationAirport.toUpperCase(),
    'weightKg': weightKg,
    'rewardOffered': rewardOffered,
    'category': category,
    if (desiredByDate != null)
      'desiredByDate': desiredByDate!.toUtc().toIso8601String(),
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}
