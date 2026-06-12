import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/requests/my_requests_screen.dart';
import 'package:tj_shipping_app/features/requests/requests_repository.dart';
import 'package:tj_shipping_app/models/package_request.dart';

import '../../support/localized_app.dart';

class _FakeRepo implements RequestsRepository {
  _FakeRepo(this._mine);
  final List<PackageRequest> _mine;

  @override
  Future<List<PackageRequest>> listMine() async => _mine;

  @override
  Future<List<PackageRequest>> search({
    String? originAirport,
    String? destinationAirport,
  }) async => _mine;

  @override
  Future<PackageRequest> findOne(String id) => throw UnimplementedError();

  @override
  Future<PackageRequest> create(CreateRequestInput input) =>
      throw UnimplementedError();

  @override
  Future<RequestOffer> createOffer(String requestId, {String? message}) =>
      throw UnimplementedError();

  @override
  Future<List<RequestOffer>> listOffers(String requestId) =>
      throw UnimplementedError();

  @override
  Future<RequestOffer> acceptOffer(String requestId, String offerId) =>
      throw UnimplementedError();
}

PackageRequest _req() => const PackageRequest(
  id: 'req_1',
  title: 'Medikamente nach Duschanbe',
  originAirport: 'FRA',
  destinationAirport: 'DYU',
  weightKg: 1.5,
  rewardOffered: 40,
  currency: 'EUR',
  category: 'MEDICINE',
  status: 'OPEN',
);

void main() {
  testWidgets('zeigt die eigenen Wünsche mit Status', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const MyRequestsScreen(),
        overrides: [
          requestsRepositoryProvider.overrideWithValue(_FakeRepo([_req()])),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Medikamente nach Duschanbe'), findsOneWidget);
    expect(find.textContaining('+40 EUR'), findsOneWidget);
    expect(find.text('OPEN'), findsOneWidget);
  });

  testWidgets('Leerzustand', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const MyRequestsScreen(),
        overrides: [
          requestsRepositoryProvider.overrideWithValue(_FakeRepo(const [])),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Du hast noch keine Wünsche gepostet.'), findsOneWidget);
  });
}
