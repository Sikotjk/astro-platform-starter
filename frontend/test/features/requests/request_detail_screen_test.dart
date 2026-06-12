import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/auth/auth_controller.dart';
import 'package:tj_shipping_app/features/auth/auth_repository.dart';
import 'package:tj_shipping_app/features/requests/request_detail_screen.dart';
import 'package:tj_shipping_app/features/requests/requests_repository.dart';
import 'package:tj_shipping_app/core/token_store.dart';
import 'package:tj_shipping_app/models/auth.dart';
import 'package:tj_shipping_app/models/package_request.dart';

import '../../support/localized_app.dart';

class _FakeRepo implements RequestsRepository {
  _FakeRepo({this.offers = const []});
  final List<RequestOffer> offers;
  String? acceptedId;

  @override
  Future<List<RequestOffer>> listOffers(String requestId) async => offers;

  @override
  Future<RequestOffer> acceptOffer(String requestId, String offerId) async {
    acceptedId = offerId;
    return offers.firstWhere((o) => o.id == offerId);
  }

  @override
  Future<RequestOffer> createOffer(String requestId, {String? message}) async =>
      const RequestOffer(id: 'new', status: 'PENDING');

  @override
  Future<List<PackageRequest>> search({
    String? originAirport,
    String? destinationAirport,
  }) async => const [];
  @override
  Future<List<PackageRequest>> listMine() async => const [];
  @override
  Future<PackageRequest> findOne(String id) => throw UnimplementedError();
  @override
  Future<PackageRequest> create(CreateRequestInput input) =>
      throw UnimplementedError();
}

class _NoAuthRepo implements AuthRepository {
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) => throw UnimplementedError();
  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'SENDER',
  }) => throw UnimplementedError();
  @override
  Future<UserProfile> me() => throw UnimplementedError();
  @override
  Future<UserProfile> updateMe({
    String? firstName,
    String? lastName,
    String? preferredLocale,
  }) => throw UnimplementedError();
  @override
  Future<void> logout(String refreshToken) => throw UnimplementedError();
}

class _FakeAuth extends AuthController {
  _FakeAuth(String userId) : super(_NoAuthRepo(), InMemoryTokenStore()) {
    state = AuthState(
      status: AuthStatus.authenticated,
      session: AuthSession(accessToken: 't', userId: userId),
    );
  }
}

PackageRequest _req({String? senderId, String status = 'OPEN'}) =>
    PackageRequest(
      id: 'req_1',
      title: 'Medikamente',
      originAirport: 'FRA',
      destinationAirport: 'DYU',
      weightKg: 1.5,
      rewardOffered: 40,
      currency: 'EUR',
      category: 'MEDICINE',
      status: status,
      sender: senderId == null
          ? null
          : RequestSender(
              id: senderId,
              firstName: 'Anvar',
              ratingAvg: 4.8,
              ratingCount: 6,
            ),
    );

void main() {
  testWidgets('Eigentümer sieht eingegangene Angebote + Annehmen', (
    tester,
  ) async {
    final repo = _FakeRepo(
      offers: const [
        RequestOffer(
          id: 'off_1',
          status: 'PENDING',
          message: 'Nehme ich gern mit',
          traveler: RequestSender(
            id: 'u_karim',
            firstName: 'Karim',
            ratingAvg: 4.7,
            ratingCount: 23,
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      localizedApp(
        RequestDetailScreen(request: _req(senderId: 'me')),
        overrides: [
          requestsRepositoryProvider.overrideWithValue(repo),
          authControllerProvider.overrideWith((ref) => _FakeAuth('me')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Karim'), findsOneWidget);
    expect(find.text('Nehme ich gern mit'), findsOneWidget);

    await tester.tap(find.byKey(const Key('accept_off_1')));
    await tester.pumpAndSettle();
    expect(repo.acceptedId, 'off_1');
  });

  testWidgets('Nicht-Eigentümer sieht den Reagieren-Button', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        RequestDetailScreen(request: _req(senderId: 'someone_else')),
        overrides: [
          requestsRepositoryProvider.overrideWithValue(_FakeRepo()),
          authControllerProvider.overrideWith((ref) => _FakeAuth('me')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reactButton')), findsOneWidget);
  });
}
