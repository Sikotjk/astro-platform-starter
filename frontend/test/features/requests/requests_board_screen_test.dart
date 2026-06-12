import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/requests/requests_board_screen.dart';
import 'package:tj_shipping_app/features/requests/requests_repository.dart';
import 'package:tj_shipping_app/models/package_request.dart';

import '../../support/localized_app.dart';

class _FakeRequestsRepo implements RequestsRepository {
  _FakeRequestsRepo(this._results);
  final List<PackageRequest> _results;
  Map<String, String?>? lastQuery;

  @override
  Future<List<PackageRequest>> search({
    String? originAirport,
    String? destinationAirport,
  }) async {
    lastQuery = {'from': originAirport, 'to': destinationAirport};
    return _results;
  }

  @override
  Future<List<PackageRequest>> listMine() async => _results;

  @override
  Future<PackageRequest> findOne(String id) => throw UnimplementedError();

  @override
  Future<PackageRequest> create(CreateRequestInput input) =>
      throw UnimplementedError();
}

PackageRequest _req() => const PackageRequest(
  id: 'req_1',
  title: 'Suche jemanden für Medikamente',
  originAirport: 'FRA',
  destinationAirport: 'DYU',
  weightKg: 1.5,
  rewardOffered: 40,
  currency: 'EUR',
  category: 'MEDICINE',
  status: 'OPEN',
  sender: RequestSender(
    id: 'u_me',
    firstName: 'Anvar',
    ratingAvg: 4.8,
    ratingCount: 6,
    kycVerified: true,
  ),
);

void main() {
  testWidgets('zeigt Wünsche mit Belohnung und Sender', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const RequestsBoardScreen(),
        overrides: [
          requestsRepositoryProvider.overrideWithValue(
            _FakeRequestsRepo([_req()]),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Suche jemanden für Medikamente'), findsOneWidget);
    expect(find.textContaining('+40 EUR'), findsOneWidget); // Belohnungs-Badge
    expect(find.text('FRA → DYU'), findsOneWidget);
    expect(find.text('Anvar'), findsOneWidget);
  });

  testWidgets('Leerzustand ohne Wünsche', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const RequestsBoardScreen(),
        overrides: [
          requestsRepositoryProvider.overrideWithValue(
            _FakeRequestsRepo(const []),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Noch keine Wünsche.'), findsOneWidget);
  });

  testWidgets('Suche reicht die Route ans Repository weiter', (tester) async {
    final repo = _FakeRequestsRepo([_req()]);
    await tester.pumpWidget(
      localizedApp(
        const RequestsBoardScreen(),
        overrides: [requestsRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('reqOrigin')), 'fra');
    await tester.enterText(find.byKey(const Key('reqDestination')), 'dyu');
    await tester.tap(find.byKey(const Key('reqSearch')));
    await tester.pumpAndSettle();

    // IATA-Formatter erzwingt Großschreibung.
    expect(repo.lastQuery, {'from': 'FRA', 'to': 'DYU'});
  });
}
