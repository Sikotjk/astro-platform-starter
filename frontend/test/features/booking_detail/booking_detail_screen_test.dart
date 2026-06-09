import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/core/token_store.dart';
import 'package:tj_shipping_app/features/auth/auth_controller.dart';
import 'package:tj_shipping_app/features/auth/auth_repository.dart';
import 'package:tj_shipping_app/features/booking_detail/booking_detail_repository.dart';
import 'package:tj_shipping_app/features/booking_detail/booking_detail_screen.dart';
import 'package:tj_shipping_app/models/auth.dart';
import 'package:tj_shipping_app/models/booking_detail.dart';

import '../../support/localized_app.dart';

class _FakeRepo implements BookingDetailRepository {
  final List<String> actedPaths = [];
  String status;
  _FakeRepo(this.status);

  @override
  Future<BookingDetail> fetch(String id) async {
    return BookingDetail(
      id: id,
      status: status,
      paymentStatus: 'PENDING',
      totalAmount: 30,
      currency: 'EUR',
      senderId: 's1',
      travelerId: 't1',
      packageTitle: 'Buch',
      termsAccepted: false,
      events: [
        BookingStatusEvent(
          toStatus: 'REQUESTED',
          triggeredBy: 's1',
          createdAt: DateTime(2026, 1, 2, 9, 30),
        ),
      ],
    );
  }

  @override
  Future<void> act(String id, String path) async {
    actedPaths.add(path);
    status = 'REJECTED';
  }

  @override
  Future<String> createEscrow(String id) async => 'pi_secret_$id';
}

class _NoRepo implements AuthRepository {
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
}

class _FakeAuth extends AuthController {
  _FakeAuth(String userId) : super(_NoRepo(), InMemoryTokenStore()) {
    state = AuthState(
      status: AuthStatus.authenticated,
      session: AuthSession(accessToken: 't', userId: userId),
    );
  }
}

void main() {
  testWidgets('zeigt Titel, Betrag und Statusverlauf', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const BookingDetailScreen(bookingId: 'b1'),
        overrides: [
          bookingDetailRepositoryProvider.overrideWithValue(
            _FakeRepo('REQUESTED'),
          ),
          authControllerProvider.overrideWith((ref) => _FakeAuth('s1')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Buch'), findsOneWidget);
    expect(find.textContaining('30.00 EUR'), findsOneWidget);
    expect(find.text('Angefragt'), findsWidgets);
  });

  testWidgets('Traveler sieht Annehmen/Ablehnen und löst Aktion aus', (
    tester,
  ) async {
    final repo = _FakeRepo('REQUESTED');
    await tester.pumpWidget(
      localizedApp(
        const BookingDetailScreen(bookingId: 'b1'),
        overrides: [
          bookingDetailRepositoryProvider.overrideWithValue(repo),
          authControllerProvider.overrideWith((ref) => _FakeAuth('t1')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('action_accept')), findsOneWidget);
    expect(find.byKey(const Key('action_reject')), findsOneWidget);

    await tester.tap(find.byKey(const Key('action_accept')));
    await tester.pumpAndSettle();

    expect(repo.actedPaths, ['accept']);
  });

  testWidgets('CONFIRMED: Beteiligter sieht den Bewerten-Button', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(
        const BookingDetailScreen(bookingId: 'b1'),
        overrides: [
          bookingDetailRepositoryProvider.overrideWithValue(
            _FakeRepo('CONFIRMED'),
          ),
          authControllerProvider.overrideWith((ref) => _FakeAuth('s1')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('action_review')), findsOneWidget);
  });

  testWidgets('IN_TRANSIT: Beteiligter sieht den Streitfall-Button', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(
        const BookingDetailScreen(bookingId: 'b1'),
        overrides: [
          bookingDetailRepositoryProvider.overrideWithValue(
            _FakeRepo('IN_TRANSIT'),
          ),
          authControllerProvider.overrideWith((ref) => _FakeAuth('s1')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('action_dispute')), findsOneWidget);
  });

  testWidgets('Fremder Nutzer sieht keine Aktionen', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const BookingDetailScreen(bookingId: 'b1'),
        overrides: [
          bookingDetailRepositoryProvider.overrideWithValue(
            _FakeRepo('REQUESTED'),
          ),
          authControllerProvider.overrideWith((ref) => _FakeAuth('x9')),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('action_accept')), findsNothing);
    expect(find.byKey(const Key('action_cancel')), findsNothing);
  });
}
