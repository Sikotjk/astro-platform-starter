import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/demo/demo_backend.dart';

void main() {
  late DemoBackend backend;

  setUp(() => backend = DemoBackend());

  Map<String, dynamic> obj(Object? body) => body as Map<String, dynamic>;
  List<dynamic> list(Object? body) => body as List<dynamic>;

  test('Login liefert eine Demo-Session', () {
    final res = backend.handle('POST', '/auth/login', {}, {
      'email': 'x',
      'password': 'y',
    });
    expect(res.statusCode, 201);
    expect(obj(res.body)['accessToken'], isNotEmpty);
    expect(obj(res.body)['userId'], DemoBackend.meId);
  });

  test('/me liefert ein verifiziertes Profil ohne sensible Felder', () {
    final res = backend.handle('GET', '/me', {}, null);
    final me = obj(res.body);
    expect(me['kycStatus'], 'VERIFIED');
    expect(me.containsKey('passwordHash'), isFalse);
  });

  test('PATCH /me übernimmt geänderte Felder', () {
    final res = backend.handle('PATCH', '/me', {}, {'firstName': 'Neu'});
    expect(obj(res.body)['firstName'], 'Neu');
  });

  test('Trip-Suche filtert nach Route und Mindestgewicht', () {
    final all = list(backend.handle('GET', '/trips', {}, null).body);
    expect(all.length, 3);

    final fraDyu = list(
      backend.handle('GET', '/trips', {
        'originAirport': 'fra',
        'destinationAirport': 'dyu',
      }, null).body,
    );
    expect(fraDyu.length, 1);
    expect(obj(fraDyu.first)['traveler']['firstName'], 'Karim');

    final heavy = list(
      backend.handle('GET', '/trips', {'minFreeKg': '15'}, null).body,
    );
    expect(heavy.every((t) => (obj(t)['freeKg'] as num) >= 15), isTrue);
  });

  test('Trip anlegen normalisiert IATA-Codes und erscheint in der Liste', () {
    final created = obj(
      backend.handle('POST', '/trips', {}, {
        'originAirport': 'txl',
        'destinationAirport': 'dyu',
        'capacityKgTotal': 5,
        'pricePerKg': 10,
      }).body,
    );
    expect(created['originAirport'], 'TXL');
    final mine = list(backend.handle('GET', '/trips/mine', {}, null).body);
    expect(mine, isNotEmpty);
  });

  test('Buchungsliste filtert nach Rolle und Status', () {
    final all = list(backend.handle('GET', '/bookings', {}, null).body);
    expect(all.length, 2);

    final confirmed = list(
      backend.handle('GET', '/bookings', {'status': 'CONFIRMED'}, null).body,
    );
    expect(confirmed.length, 1);

    final asTraveler = list(
      backend.handle('GET', '/bookings', {'role': 'TRAVELER'}, null).body,
    );
    expect(asTraveler, isEmpty); // Demo-Nutzer ist Sender beider Buchungen
  });

  test('Buchungsdetail enthält Timeline und Gegenpartei', () {
    final b = obj(backend.handle('GET', '/bookings/b_1', {}, null).body);
    expect(b['status'], 'CONFIRMED');
    expect((b['statusEvents'] as List).length, 6);
    expect(obj(b['traveler'])['firstName'], 'Karim');
  });

  test('unbekannte Buchung liefert 404', () {
    expect(backend.handle('GET', '/bookings/nope', {}, null).statusCode, 404);
  });

  test('Chat: senden hängt an und ist danach abrufbar', () {
    final countBefore = list(
      backend.handle('GET', '/bookings/b_1/messages', {}, null).body,
    ).length;
    backend.handle('POST', '/bookings/b_1/messages', {}, {'body': 'Hallo!'});
    final after = list(
      backend.handle('GET', '/bookings/b_1/messages', {}, null).body,
    );
    expect(after.length, countBefore + 1);
    expect(obj(after.last)['body'], 'Hallo!');
    expect(obj(after.last)['senderId'], DemoBackend.meId);
  });

  test('Buchungsaktion ändert Status und schreibt ein Event', () {
    final res = backend.handle('POST', '/bookings/b_2/accept', {}, null);
    expect(res.statusCode, 201);
    final b = obj(res.body);
    expect(b['status'], 'ACCEPTED');
    expect((b['statusEvents'] as List).last['toStatus'], 'ACCEPTED');
  });

  test('confirm setzt RELEASED', () {
    final b = obj(
      backend.handle('POST', '/bookings/b_1/confirm', {}, null).body,
    );
    expect(b['status'], 'CONFIRMED');
    expect(b['paymentStatus'], 'RELEASED');
  });

  test('Manifest liefert ein PDF', () {
    final res = backend.handle('GET', '/bookings/b_1/manifest', {}, null);
    expect(res.contentType, 'application/pdf');
    expect(res.bytes, isNotNull);
    // Beginnt mit der PDF-Signatur „%PDF".
    expect(res.bytes!.sublist(0, 4), [0x25, 0x50, 0x44, 0x46]);
  });

  test('Bewertungen pro Nutzer abrufbar', () {
    final reviews = list(
      backend
          .handle('GET', '/users/${DemoBackend.karimId}/reviews', {}, null)
          .body,
    );
    expect(reviews.length, greaterThanOrEqualTo(2));
  });

  test('Gespeicherte Suchen: anlegen, listen, löschen', () {
    final created = obj(
      backend.handle('POST', '/saved-searches', {}, {
        'originAirport': 'MUC',
        'destinationAirport': 'DYU',
      }).body,
    );
    var all = list(backend.handle('GET', '/saved-searches', {}, null).body);
    expect(all.length, 2);

    backend.handle('DELETE', '/saved-searches/${created['id']}', {}, null);
    all = list(backend.handle('GET', '/saved-searches', {}, null).body);
    expect(all.length, 1);
  });

  test('Benachrichtigungen: read-all markiert alle als gelesen', () {
    final unreadBefore = list(
      backend.handle('GET', '/notifications', {'unread': 'true'}, null).body,
    );
    expect(unreadBefore, isNotEmpty);

    final res = obj(
      backend.handle('POST', '/notifications/read-all', {}, null).body,
    );
    expect(res['updated'], unreadBefore.length);

    final unreadAfter = list(
      backend.handle('GET', '/notifications', {'unread': 'true'}, null).body,
    );
    expect(unreadAfter, isEmpty);
  });

  test('KYC-Status ist im Demo verifiziert', () {
    final res = obj(backend.handle('GET', '/kyc/status', {}, null).body);
    expect(res['status'], 'VERIFIED');
  });

  test('Paket anlegen liefert ALLOW-Deklaration', () {
    final res = obj(
      backend.handle('POST', '/packages', {}, {'title': 'x'}).body,
    );
    expect(obj(res['declaration'])['level'], 'ALLOW');
    expect(obj(res['package'])['id'], isNotEmpty);
  });

  group('Wunsch-Board', () {
    test('listet offene Wünsche inkl. Sender', () {
      final all = list(backend.handle('GET', '/requests', {}, null).body);
      expect(all.length, greaterThanOrEqualTo(3));
      expect(obj(all.first)['sender']['firstName'], isNotEmpty);
    });

    test('filtert nach Route', () {
      final fraDyu = list(
        backend.handle('GET', '/requests', {
          'originAirport': 'fra',
          'destinationAirport': 'dyu',
        }, null).body,
      );
      expect(fraDyu, isNotEmpty);
      expect(
        fraDyu.every(
          (r) =>
              obj(r)['originAirport'] == 'FRA' &&
              obj(r)['destinationAirport'] == 'DYU',
        ),
        isTrue,
      );
    });

    test('Wunsch posten normalisiert IATA und erscheint im Board', () {
      final before = list(
        backend.handle('GET', '/requests', {}, null).body,
      ).length;
      final created = obj(
        backend.handle('POST', '/requests', {}, {
          'title': 'Test-Wunsch',
          'originAirport': 'txl',
          'destinationAirport': 'dyu',
          'weightKg': 2,
          'rewardOffered': 30,
          'category': 'GIFTS',
        }).body,
      );
      expect(created['originAirport'], 'TXL');
      expect(created['status'], 'OPEN');
      final after = list(backend.handle('GET', '/requests', {}, null).body);
      expect(after.length, before + 1);
    });

    test('mine liefert die eigenen Wünsche', () {
      final mine = list(backend.handle('GET', '/requests/mine', {}, null).body);
      expect(mine, isNotEmpty);
      expect(
        mine.every((r) => obj(r)['sender']['id'] == DemoBackend.meId),
        isTrue,
      );
    });

    test('Einzelwunsch abrufbar', () {
      final r = obj(backend.handle('GET', '/requests/req_1', {}, null).body);
      expect(r['title'], contains('Medikamente'));
    });
  });
}
