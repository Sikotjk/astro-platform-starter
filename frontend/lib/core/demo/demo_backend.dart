import 'dart:convert';

/// Antwort des Demo-Backends: Status + JSON-Body (oder rohe Bytes fürs PDF).
class DemoResponse {
  const DemoResponse(
    this.statusCode,
    this.body, {
    this.bytes,
    this.contentType,
  });

  final int statusCode;
  final Object? body; // wird als JSON serialisiert, wenn [bytes] null ist
  final List<int>? bytes;
  final String? contentType;
}

/// In-Memory-„Backend" für den Demo-Modus: beantwortet dieselben REST-Routen
/// wie die echte API mit glaubwürdigen Fakedaten — ganz ohne Server, Stripe
/// oder Datenbank. Zustandsbehaftet: gesendete Chat-Nachrichten, Buchungs-
/// Statuswechsel, gespeicherte Suchen usw. bleiben für die Sitzung erhalten.
///
/// Reine Dart-Logik (kein Dio) → unabhängig testbar.
class DemoBackend {
  DemoBackend() {
    _seed();
  }

  // ── IDs ────────────────────────────────────────────────────────────────────
  static const meId = 'u_me';
  static const karimId = 'u_karim';
  static const salimId = 'u_salim';
  static const firuzaId = 'u_firuza';

  final DateTime _now = DateTime.now();

  late List<Map<String, dynamic>> _trips;
  late Map<String, Map<String, dynamic>> _bookings;
  late Map<String, List<Map<String, dynamic>>> _messages;
  late List<Map<String, dynamic>> _savedSearches;
  late List<Map<String, dynamic>> _notifications;
  late Map<String, List<Map<String, dynamic>>> _reviews;
  late List<Map<String, dynamic>> _requests;
  late Map<String, List<Map<String, dynamic>>> _offers;
  int _seq = 0;

  String _id(String prefix) => '${prefix}_${++_seq}';
  String _iso(DateTime d) => d.toUtc().toIso8601String();

  Map<String, dynamic> _party(String id, String name, double avg, int count) =>
      {
        'id': id,
        'firstName': name,
        'ratingAvg': avg,
        'ratingCount': count,
        // Neue Reisende (ohne Bewertungen) sind im Demo noch unverifiziert.
        'kycStatus': count > 0 ? 'VERIFIED' : 'NOT_STARTED',
      };

  void _seed() {
    String inDays(int d) => _iso(_now.add(Duration(days: d)));
    String agoDays(int d) => _iso(_now.subtract(Duration(days: d)));

    _trips = [
      {
        'id': 't_1',
        'originAirport': 'FRA',
        'destinationAirport': 'DYU',
        'departureAt': inDays(9),
        'departureGate': 'B27',
        'freeKg': 12.0,
        'pricePerKg': '8.00',
        'currency': 'EUR',
        'status': 'ACTIVE',
        'traveler': _party(karimId, 'Karim', 4.7, 23),
      },
      {
        'id': 't_2',
        'originAirport': 'MUC',
        'destinationAirport': 'DYU',
        'departureAt': inDays(16),
        'freeKg': 6.0,
        'pricePerKg': '9.50',
        'currency': 'EUR',
        'status': 'ACTIVE',
        'traveler': _party(salimId, 'Salim', 5.0, 8),
      },
      {
        'id': 't_3',
        'originAirport': 'FRA',
        'destinationAirport': 'LBD',
        'departureAt': inDays(23),
        'freeKg': 20.0,
        'pricePerKg': '7.00',
        'currency': 'EUR',
        'status': 'ACTIVE',
        'traveler': _party(firuzaId, 'Firuza', 0, 0),
      },
    ];

    final pkg1 = {
      'title': 'Geschenke für die Familie',
      'items': [
        {
          'category': 'CLOTHING',
          'description': 'Winterjacke (neu)',
          'quantity': 1,
          'unitValueEur': 60,
          'isSealed': false,
        },
        {
          'category': 'GIFTS',
          'description': 'Spielzeug',
          'quantity': 2,
          'unitValueEur': 15,
          'isSealed': false,
        },
      ],
    };
    final pkg2 = {
      'title': 'Wichtige Dokumente',
      'items': [
        {
          'category': 'DOCUMENTS',
          'description': 'Beglaubigte Kopien',
          'quantity': 1,
          'unitValueEur': 0,
          'isSealed': true,
        },
      ],
    };

    _bookings = {
      'b_1': {
        'id': 'b_1',
        'status': 'CONFIRMED',
        'paymentStatus': 'RELEASED',
        'totalAmount': '27.60',
        'currency': 'EUR',
        'senderId': meId,
        'travelerId': karimId,
        'travelerAcceptedTermsAt': agoDays(5),
        'package': pkg1,
        'trip': {
          'originAirport': 'FRA',
          'destinationAirport': 'DYU',
          'departureAt': agoDays(2),
        },
        'sender': _party(meId, 'Anvar', 4.8, 6),
        'traveler': _party(karimId, 'Karim', 4.7, 23),
        'statusEvents': [
          {
            'toStatus': 'ACCEPTED',
            'triggeredBy': karimId,
            'createdAt': agoDays(8),
          },
          {'toStatus': 'PAID', 'triggeredBy': meId, 'createdAt': agoDays(7)},
          {
            'toStatus': 'HANDED_OVER',
            'triggeredBy': meId,
            'createdAt': agoDays(6),
          },
          {
            'toStatus': 'IN_TRANSIT',
            'triggeredBy': karimId,
            'createdAt': agoDays(2),
          },
          {
            'toStatus': 'DELIVERED',
            'triggeredBy': karimId,
            'createdAt': agoDays(1),
          },
          {
            'toStatus': 'CONFIRMED',
            'triggeredBy': meId,
            'createdAt': agoDays(1),
          },
        ],
      },
      'b_2': {
        'id': 'b_2',
        'status': 'REQUESTED',
        'paymentStatus': 'PENDING',
        'totalAmount': '19.00',
        'currency': 'EUR',
        'senderId': meId,
        'travelerId': salimId,
        'travelerAcceptedTermsAt': null,
        'package': pkg2,
        'trip': {
          'originAirport': 'MUC',
          'destinationAirport': 'DYU',
          'departureAt': inDays(16),
        },
        'sender': _party(meId, 'Anvar', 4.8, 6),
        'traveler': _party(salimId, 'Salim', 5.0, 8),
        'statusEvents': [
          {
            'toStatus': 'REQUESTED',
            'triggeredBy': meId,
            'createdAt': agoDays(1),
          },
        ],
      },
    };

    _messages = {
      'b_1': [
        _msg(
          'b_1',
          karimId,
          'Hallo Anvar, ich nehme das Paket gerne mit.',
          agoDays(8),
        ),
        _msg(
          'b_1',
          meId,
          'Super, vielen Dank! Wann kann ich es übergeben?',
          agoDays(7),
        ),
        _msg(
          'b_1',
          karimId,
          'Morgen am Flughafen, Terminal 1. Bis dann!',
          agoDays(6),
        ),
      ],
      'b_2': [],
    };

    _savedSearches = [
      {
        'id': 's_1',
        'originAirport': 'FRA',
        'destinationAirport': 'DYU',
        'minFreeKg': 5,
      },
    ];

    _notifications = [
      {
        'id': 'n_1',
        'type': 'TRIP_MATCH',
        'title': 'Neuer passender Flug',
        'body': 'Karim fliegt FRA → DYU mit 12 kg freiem Gepäck.',
        'tripId': 't_1',
        'readAt': null,
        'createdAt': agoDays(1),
      },
      {
        'id': 'n_2',
        'type': 'BOOKING_UPDATE',
        'title': 'Lieferung bestätigt',
        'body': 'Deine Sendung „Geschenke für die Familie" wurde zugestellt.',
        'tripId': null,
        'readAt': agoDays(1),
        'createdAt': agoDays(1),
      },
    ];

    _reviews = {
      karimId: [
        _review(
          'Sehr zuverlässig und freundlich. Gerne wieder!',
          5,
          'Anvar',
          agoDays(1),
        ),
        _review('Alles pünktlich angekommen.', 5, 'Dilnoza', agoDays(30)),
        _review('Gute Kommunikation.', 4, 'Rustam', agoDays(60)),
      ],
      meId: [
        _review(
          'Paket war gut verpackt, klare Absprachen.',
          5,
          'Karim',
          agoDays(1),
        ),
      ],
      salimId: [_review('Top!', 5, 'Madina', agoDays(10))],
      firuzaId: [],
    };

    _requests = [
      {
        'id': 'req_1',
        'title': 'Suche jemanden für Medikamente',
        'originAirport': 'FRA',
        'destinationAirport': 'DYU',
        'desiredByDate': inDays(20),
        'weightKg': '1.50',
        'rewardOffered': '40.00',
        'currency': 'EUR',
        'category': 'MEDICINE',
        'notes': 'Bitte kühl transportieren, geht an meine Mutter.',
        'status': 'OPEN',
        'createdAt': agoDays(1),
        'sender': _party(meId, 'Anvar', 4.8, 6),
      },
      {
        'id': 'req_2',
        'title': 'Dokumente nach Chudschand',
        'originAirport': 'MUC',
        'destinationAirport': 'LBD',
        'desiredByDate': inDays(30),
        'weightKg': '0.50',
        'rewardOffered': '25.00',
        'currency': 'EUR',
        'category': 'DOCUMENTS',
        'notes': null,
        'status': 'OPEN',
        'createdAt': agoDays(2),
        'sender': _party(salimId, 'Salim', 5.0, 8),
      },
      {
        'id': 'req_3',
        'title': 'Geschenke für die Hochzeit',
        'originAirport': 'FRA',
        'destinationAirport': 'DYU',
        'desiredByDate': inDays(12),
        'weightKg': '4.00',
        'rewardOffered': '60.00',
        'currency': 'EUR',
        'category': 'GIFTS',
        'notes': 'Mehrere kleinere Päckchen.',
        'status': 'OPEN',
        'createdAt': agoDays(3),
        'sender': _party(firuzaId, 'Firuza', 0, 0),
      },
    ];

    // Auf den eigenen Wunsch (req_1) liegt bereits ein Angebot von Karim.
    _offers = {
      'req_1': [
        {
          'id': 'off_1',
          'requestId': 'req_1',
          'message': 'Ich fliege nächste Woche FRA → DYU, nehme es gern mit!',
          'status': 'PENDING',
          'createdAt': agoDays(0),
          'traveler': _party(karimId, 'Karim', 4.7, 23),
        },
      ],
    };
  }

  Map<String, dynamic> _msg(
    String bookingId,
    String senderId,
    String body,
    String createdAt,
  ) => {
    'id': _id('m'),
    'bookingId': bookingId,
    'senderId': senderId,
    'body': body,
    'createdAt': createdAt,
  };

  Map<String, dynamic> _review(
    String comment,
    int rating,
    String author,
    String createdAt,
  ) => {
    'id': _id('r'),
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt,
    'author': {'firstName': author, 'avatarUrl': null},
  };

  Map<String, dynamic> get _meProfile => {
    'id': meId,
    'email': 'demo@tj-shipping.app',
    'firstName': 'Anvar',
    'lastName': 'Demo',
    'role': 'SENDER',
    'preferredLocale': 'de',
    'kycStatus': 'VERIFIED',
    'ratingAvg': 4.8,
    'ratingCount': 6,
  };

  Map<String, dynamic> _session() => {
    'accessToken': 'demo-access-token',
    'refreshToken': 'demo-refresh-token',
    'userId': meId,
  };

  /// Zentrale Route → Antwort. [path] ohne Query, [query]/[body] optional.
  DemoResponse handle(
    String method,
    String path,
    Map<String, String> query,
    Map<String, dynamic>? body,
  ) {
    final segs = path.split('/').where((s) => s.isNotEmpty).toList();
    final m = method.toUpperCase();

    // ── Auth ──────────────────────────────────────────────────────────────────
    if (path == '/auth/login' || path == '/auth/register') {
      return DemoResponse(201, _session());
    }
    if (path == '/auth/refresh') return DemoResponse(201, _session());
    if (path == '/auth/logout') return const DemoResponse(201, {'ok': true});
    if (path == '/me') {
      if (m == 'PATCH' && body != null) {
        final p = Map<String, dynamic>.from(_meProfile);
        for (final k in ['firstName', 'lastName', 'preferredLocale']) {
          if (body[k] != null) p[k] = body[k];
        }
        return DemoResponse(200, p);
      }
      return DemoResponse(200, _meProfile);
    }

    // ── Trips ─────────────────────────────────────────────────────────────────
    if (path == '/trips/mine') {
      return DemoResponse(200, [_trips.first]);
    }
    if (path == '/trips' && m == 'GET') {
      return DemoResponse(200, _searchTrips(query));
    }
    if (path == '/trips' && m == 'POST') {
      final t = {
        'id': _id('t'),
        'originAirport': (body?['originAirport'] ?? 'FRA')
            .toString()
            .toUpperCase(),
        'destinationAirport': (body?['destinationAirport'] ?? 'DYU')
            .toString()
            .toUpperCase(),
        'departureAt':
            body?['departureAt'] ?? _iso(_now.add(const Duration(days: 14))),
        'freeKg': (body?['capacityKgTotal'] as num?)?.toDouble() ?? 10.0,
        'pricePerKg': (body?['pricePerKg'] ?? 8).toString(),
        'currency': body?['currency'] ?? 'EUR',
        'status': 'ACTIVE',
        'traveler': _party(meId, 'Anvar', 4.8, 6),
      };
      _trips.insert(0, t);
      return DemoResponse(201, t);
    }
    if (segs.length == 2 && segs[0] == 'trips') {
      final t = _trips.firstWhere(
        (e) => e['id'] == segs[1],
        orElse: () => _trips.first,
      );
      return DemoResponse(200, t);
    }

    // ── Wunsch-Board (umgekehrter Marktplatz) ────────────────────────────────────
    if (path == '/requests/mine') {
      final mine = _requests
          .where((r) => (r['sender'] as Map)['id'] == meId)
          .toList();
      return DemoResponse(200, mine);
    }
    if (path == '/requests' && m == 'GET') {
      return DemoResponse(200, _searchRequests(query));
    }
    if (path == '/requests' && m == 'POST') {
      final r = {
        'id': _id('req'),
        'title': (body?['title'] ?? 'Wunsch').toString(),
        'originAirport': (body?['originAirport'] ?? 'FRA')
            .toString()
            .toUpperCase(),
        'destinationAirport': (body?['destinationAirport'] ?? 'DYU')
            .toString()
            .toUpperCase(),
        'desiredByDate': body?['desiredByDate'],
        'weightKg': (body?['weightKg'] ?? 1).toString(),
        'rewardOffered': (body?['rewardOffered'] ?? 0).toString(),
        'currency': body?['currency'] ?? 'EUR',
        'category': body?['category'] ?? 'OTHER',
        'notes': body?['notes'],
        'status': 'OPEN',
        'createdAt': _iso(_now),
        'sender': _party(meId, 'Anvar', 4.8, 6),
      };
      _requests.insert(0, r);
      return DemoResponse(201, r);
    }
    // Angebote: /requests/:id/offers  und  .../offers/:offerId/accept
    if (segs.length >= 3 && segs[0] == 'requests' && segs[2] == 'offers') {
      return _offersRoute(m, segs, body);
    }
    if (segs.length == 2 && segs[0] == 'requests') {
      final r = _requests.firstWhere(
        (e) => e['id'] == segs[1],
        orElse: () => _requests.first,
      );
      return DemoResponse(200, r);
    }

    // ── Bookings ───────────────────────────────────────────────────────────────
    if (path == '/bookings' && m == 'GET') {
      final role = query['role'];
      final status = query['status'];
      var list = _bookings.values.toList();
      if (role == 'TRAVELER') {
        list = list.where((b) => b['travelerId'] == meId).toList();
      } else if (role == 'SENDER') {
        list = list.where((b) => b['senderId'] == meId).toList();
      }
      if (status != null) {
        list = list.where((b) => b['status'] == status).toList();
      }
      return DemoResponse(200, list);
    }
    if (path == '/bookings' && m == 'POST') {
      return DemoResponse(201, _bookings['b_2']);
    }
    if (segs.length == 2 && segs[0] == 'bookings' && m == 'GET') {
      return _bookingOr404(segs[1]);
    }
    if (segs.length >= 3 && segs[0] == 'bookings') {
      return _bookingSubroute(m, segs, body);
    }

    // ── Packages ───────────────────────────────────────────────────────────────
    if (path == '/packages' && m == 'POST') {
      return DemoResponse(201, {
        'package': {'id': _id('pkg')},
        'declaration': {'level': 'ALLOW', 'declarable': true, 'notes': []},
      });
    }

    // ── Customs ────────────────────────────────────────────────────────────────
    if (path == '/customs/evaluate') {
      return const DemoResponse(201, {
        'level': 'ALLOW',
        'declarable': true,
        'notes': [],
      });
    }

    // ── KYC ────────────────────────────────────────────────────────────────────
    if (path == '/kyc/session') {
      return const DemoResponse(201, {'clientSecret': 'demo_kyc_secret'});
    }
    if (path == '/kyc/status') {
      return const DemoResponse(200, {'status': 'VERIFIED'});
    }

    // ── Reviews ────────────────────────────────────────────────────────────────
    if (segs.length == 3 && segs[0] == 'users' && segs[2] == 'reviews') {
      return DemoResponse(200, _reviews[segs[1]] ?? const []);
    }

    // ── Saved Searches ─────────────────────────────────────────────────────────
    if (path == '/saved-searches' && m == 'GET') {
      return DemoResponse(200, _savedSearches);
    }
    if (path == '/saved-searches' && m == 'POST') {
      final s = {
        'id': _id('s'),
        'originAirport': body?['originAirport'],
        'destinationAirport': body?['destinationAirport'],
        'minFreeKg': body?['minFreeKg'],
      };
      _savedSearches.add(s);
      return DemoResponse(201, s);
    }
    if (segs.length == 2 && segs[0] == 'saved-searches' && m == 'DELETE') {
      _savedSearches.removeWhere((e) => e['id'] == segs[1]);
      return const DemoResponse(200, {'ok': true});
    }

    // ── Notifications ──────────────────────────────────────────────────────────
    if (path == '/notifications' && m == 'GET') {
      final unread = query['unread'] == 'true';
      final list = unread
          ? _notifications.where((n) => n['readAt'] == null).toList()
          : _notifications;
      return DemoResponse(200, list);
    }
    if (path == '/notifications/read-all' && m == 'POST') {
      var updated = 0;
      for (final n in _notifications) {
        if (n['readAt'] == null) {
          n['readAt'] = _iso(_now);
          updated++;
        }
      }
      return DemoResponse(201, {'updated': updated});
    }
    if (segs.length == 3 && segs[0] == 'notifications' && segs[2] == 'read') {
      for (final n in _notifications) {
        if (n['id'] == segs[1]) n['readAt'] = _iso(_now);
      }
      return const DemoResponse(201, {'ok': true});
    }

    // ── Devices (Push) ─────────────────────────────────────────────────────────
    if (path == '/devices') {
      return DemoResponse(
        m == 'GET' ? 200 : 201,
        m == 'GET' ? [] : {'id': 'demo'},
      );
    }

    // Unbekannte Route → leeres, freundliches 200 (Demo soll nie hart scheitern).
    return const DemoResponse(200, {});
  }

  List<Map<String, dynamic>> _searchTrips(Map<String, String> query) {
    final from = query['originAirport']?.toUpperCase();
    final to = query['destinationAirport']?.toUpperCase();
    final minKg = double.tryParse(query['minFreeKg'] ?? '');
    return _trips.where((t) {
      if (t['status'] != 'ACTIVE') return false;
      if (from != null && from.isNotEmpty && t['originAirport'] != from) {
        return false;
      }
      if (to != null && to.isNotEmpty && t['destinationAirport'] != to) {
        return false;
      }
      if (minKg != null && (t['freeKg'] as num) < minKg) return false;
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _searchRequests(Map<String, String> query) {
    final from = query['originAirport']?.toUpperCase();
    final to = query['destinationAirport']?.toUpperCase();
    return _requests.where((r) {
      if (r['status'] != 'OPEN') return false;
      if (from != null && from.isNotEmpty && r['originAirport'] != from) {
        return false;
      }
      if (to != null && to.isNotEmpty && r['destinationAirport'] != to) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Routen rund um Angebote auf einen Wunsch.
  DemoResponse _offersRoute(
    String method,
    List<String> segs,
    Map<String, dynamic>? body,
  ) {
    final requestId = segs[1];
    final req = _requests.firstWhere(
      (e) => e['id'] == requestId,
      orElse: () => {},
    );
    if (req.isEmpty) {
      return const DemoResponse(404, {'message': 'Wunsch nicht gefunden.'});
    }
    final list = _offers[requestId] ?? [];

    // .../offers/:offerId/accept
    if (segs.length == 5 && segs[4] == 'accept') {
      final offerId = segs[3];
      for (final o in list) {
        o['status'] = o['id'] == offerId ? 'ACCEPTED' : 'DECLINED';
      }
      req['status'] = 'MATCHED';
      final accepted = list.firstWhere(
        (o) => o['id'] == offerId,
        orElse: () => {},
      );
      return DemoResponse(201, accepted);
    }

    // /requests/:id/offers
    if (method == 'GET') return DemoResponse(200, list);

    // POST: ich (Demo-Nutzer) gebe ein Angebot ab.
    final offer = {
      'id': _id('off'),
      'requestId': requestId,
      'message': body?['message'],
      'status': 'PENDING',
      'createdAt': _iso(_now),
      'traveler': _party(meId, 'Anvar', 4.8, 6),
    };
    list.add(offer);
    _offers[requestId] = list;
    return DemoResponse(201, offer);
  }

  DemoResponse _bookingOr404(String id) {
    final b = _bookings[id];
    return b == null
        ? const DemoResponse(404, {'message': 'Buchung nicht gefunden.'})
        : DemoResponse(200, b);
  }

  static const _actionStatus = {
    'accept': 'ACCEPTED',
    'reject': 'REJECTED',
    'escrow': 'PAID',
    'handover': 'HANDED_OVER',
    'transit': 'IN_TRANSIT',
    'delivered': 'DELIVERED',
    'confirm': 'CONFIRMED',
    'cancel': 'CANCELLED',
    'dispute': 'DISPUTED',
  };

  DemoResponse _bookingSubroute(
    String method,
    List<String> segs,
    Map<String, dynamic>? body,
  ) {
    final id = segs[1];
    final action = segs[2];
    final booking = _bookings[id];
    if (booking == null) {
      return const DemoResponse(404, {'message': 'Buchung nicht gefunden.'});
    }

    if (action == 'messages') {
      final list = _messages[id] ?? [];
      if (method == 'GET') return DemoResponse(200, list);
      final msg = _msg(id, meId, (body?['body'] ?? '').toString(), _iso(_now));
      list.add(msg);
      _messages[id] = list;
      return DemoResponse(201, msg);
    }

    if (action == 'manifest') {
      return DemoResponse(
        200,
        null,
        bytes: base64Decode(_demoPdfBase64),
        contentType: 'application/pdf',
      );
    }

    if (action == 'review') {
      final list = _reviews[booking['travelerId']] ?? [];
      final review = _review(
        (body?['comment'] ?? '').toString(),
        (body?['rating'] as num?)?.toInt() ?? 5,
        'Anvar',
        _iso(_now),
      );
      list.insert(0, review);
      _reviews[booking['travelerId'] as String] = list;
      return DemoResponse(201, review);
    }

    if (action == 'escrow') {
      _applyStatus(booking, 'PAID', extraPayment: 'ESCROW_HELD');
      return const DemoResponse(201, {'clientSecret': 'demo_pi_secret'});
    }

    final next = _actionStatus[action];
    if (next != null) {
      if (action == 'confirm') {
        _applyStatus(booking, next, extraPayment: 'RELEASED');
      } else {
        _applyStatus(booking, next);
      }
      if (action == 'accept' || action == 'handover') {
        booking['travelerAcceptedTermsAt'] ??= _iso(_now);
      }
      return DemoResponse(201, booking);
    }

    if (action == 'accept-terms') {
      booking['travelerAcceptedTermsAt'] = _iso(_now);
      return DemoResponse(201, booking);
    }

    return DemoResponse(201, booking);
  }

  void _applyStatus(
    Map<String, dynamic> booking,
    String status, {
    String? extraPayment,
  }) {
    booking['status'] = status;
    if (extraPayment != null) booking['paymentStatus'] = extraPayment;
    (booking['statusEvents'] as List).add({
      'toStatus': status,
      'triggeredBy': meId,
      'createdAt': _iso(_now),
    });
  }
}

/// Minimal gültiges Ein-Seiten-PDF (Demo-Zoll-Manifest).
const _demoPdfBase64 =
    'JVBERi0xLjQKMSAwIG9iago8PCAvVHlwZSAvQ2F0YWxvZyAvUGFnZXMgMiAwIFIgPj4KZW5kb2JqCjIg'
    'MCBvYmoKPDwgL1R5cGUgL1BhZ2VzIC9LaWRzIFszIDAgUl0gL0NvdW50IDEgPj4KZW5kb2JqCjMgMCBv'
    'YmoKPDwgL1R5cGUgL1BhZ2UgL1BhcmVudCAyIDAgUiAvTWVkaWFCb3ggWzAgMCAzMjAgMjIwXSAvQ29u'
    'dGVudHMgNCAwIFIgL1Jlc291cmNlcyA8PCAvRm9udCA8PCAvRjEgNSAwIFIgPj4gPj4gPj4KZW5kb2Jq'
    'CjQgMCBvYmoKPDwgL0xlbmd0aCAxMDAgPj4Kc3RyZWFtCkJUIC9GMSAxNiBUZiAzMCAxNzAgVGQgKFRK'
    'LVNoaXBwaW5nKSBUaiAwIC0yOCBUZCAoRGVtbyBab2xsLU1hbmlmZXN0KSBUaiAwIC0yOCBUZCAoRlJB'
    'IC0+IERZVSkgVGogRVQKZW5kc3RyZWFtCmVuZG9iago1IDAgb2JqCjw8IC9UeXBlIC9Gb250IC9TdWJ0'
    'eXBlIC9UeXBlMSAvQmFzZUZvbnQgL0hlbHZldGljYSA+PgplbmRvYmoKeHJlZgowIDYKMDAwMDAwMDAw'
    'MCA2NTUzNSBmIAowMDAwMDAwMDA5IDAwMDAwIG4gCjAwMDAwMDAwNTggMDAwMDAgbiAKMDAwMDAwMDEx'
    'NSAwMDAwMCBuIAowMDAwMDAwMjQxIDAwMDAwIG4gCjAwMDAwMDAzOTIgMDAwMDAgbiAKdHJhaWxlcgo8'
    'PCAvU2l6ZSA2IC9Sb290IDEgMCBSID4+CnN0YXJ0eHJlZgo0NjIKJSVFT0Y=';
