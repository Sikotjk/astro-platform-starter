import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tj_shipping_app/core/localization_delegates.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/notifications/notifications_repository.dart';
import 'package:tj_shipping_app/features/notifications/notifications_screen.dart';
import 'package:tj_shipping_app/features/trips/trips_repository.dart';
import 'package:tj_shipping_app/l10n/app_localizations.dart';
import 'package:tj_shipping_app/models/notification.dart';
import 'package:tj_shipping_app/models/trip.dart';

import '../../support/localized_app.dart';

class _FakeNotifRepo implements NotificationsRepository {
  _FakeNotifRepo(this._items);
  final List<NotificationItem> _items;
  final List<String> readIds = [];
  bool? lastUnreadOnly;

  @override
  Future<List<NotificationItem>> list({bool unreadOnly = false}) async {
    lastUnreadOnly = unreadOnly;
    return List.of(_items);
  }

  @override
  Future<void> markAllRead() async {}

  @override
  Future<void> markRead(String id) async => readIds.add(id);
}

class _FakeTripsRepo implements TripsRepository {
  String? requestedId;

  @override
  Future<List<Trip>> search(TripSearchQuery query) =>
      throw UnimplementedError();

  @override
  Future<Trip> findOne(String id) async {
    requestedId = id;
    return Trip(
      id: id,
      originAirport: 'FRA',
      destinationAirport: 'DYU',
      departureAt: DateTime.parse('2026-09-01T10:00:00Z'),
      freeKg: 10,
      pricePerKg: 8,
      currency: 'EUR',
    );
  }
}

NotificationItem _notif({String id = 'n1', String? tripId}) => NotificationItem(
  id: id,
  type: 'TRIP_MATCH',
  title: 'Neuer Trip FRA → DYU',
  body: 'Ein passender Trip wurde eingestellt.',
  createdAt: DateTime(2026),
  tripId: tripId,
);

void main() {
  testWidgets('Tippen markiert als gelesen', (tester) async {
    final repo = _FakeNotifRepo([_notif()]); // ohne tripId -> keine Navigation
    await tester.pumpWidget(
      localizedApp(
        const NotificationsScreen(),
        overrides: [notificationsRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Neuer Trip FRA → DYU'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing); // kein tripId

    await tester.tap(find.text('Neuer Trip FRA → DYU'));
    await tester.pumpAndSettle();

    expect(repo.readIds, ['n1']);
  });

  testWidgets('Filter "Ungelesen" lädt mit unreadOnly neu', (tester) async {
    final repo = _FakeNotifRepo([_notif()]);
    await tester.pumpWidget(
      localizedApp(
        const NotificationsScreen(),
        overrides: [notificationsRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();
    expect(repo.lastUnreadOnly, isFalse); // initial: alle

    await tester.tap(find.text('Ungelesen'));
    await tester.pumpAndSettle();

    expect(repo.lastUnreadOnly, isTrue);
  });

  testWidgets('Trip-Treffer mit tripId navigiert zur Buchungsansicht', (
    tester,
  ) async {
    final notifRepo = _FakeNotifRepo([_notif(tripId: 't1')]);
    final tripsRepo = _FakeTripsRepo();

    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const NotificationsScreen()),
        GoRoute(
          path: '/book',
          builder: (_, state) => Text('BOOK ${(state.extra as Trip).id}'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(notifRepo),
          tripsRepositoryProvider.overrideWithValue(tripsRepo),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byIcon(Icons.chevron_right),
      findsOneWidget,
    ); // tripId vorhanden

    await tester.tap(find.text('Neuer Trip FRA → DYU'));
    await tester.pumpAndSettle();

    expect(notifRepo.readIds, ['n1']);
    expect(tripsRepo.requestedId, 't1');
    expect(find.text('BOOK t1'), findsOneWidget); // navigiert nach /book
  });
}
