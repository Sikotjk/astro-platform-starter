import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/saved_searches/saved_searches_repository.dart';
import 'package:tj_shipping_app/features/saved_searches/saved_searches_screen.dart';
import 'package:tj_shipping_app/models/saved_search.dart';

import '../../support/localized_app.dart';

class _FakeRepo implements SavedSearchesRepository {
  final List<SavedSearch> items = [
    const SavedSearch(
      id: 's1',
      originAirport: 'FRA',
      destinationAirport: 'DYU',
    ),
    const SavedSearch(
      id: 's2',
      originAirport: 'BER',
      destinationAirport: 'LBD',
    ),
  ];
  final List<String> removed = [];

  @override
  Future<List<SavedSearch>> list() async => List.of(items);

  @override
  Future<SavedSearch> create({
    String? originAirport,
    String? destinationAirport,
    double? minFreeKg,
  }) => throw UnimplementedError();

  @override
  Future<void> remove(String id) async {
    removed.add(id);
    items.removeWhere((s) => s.id == id);
  }
}

void main() {
  testWidgets('listet gespeicherte Suchen und löscht eine', (tester) async {
    final repo = _FakeRepo();
    await tester.pumpWidget(
      localizedApp(
        const SavedSearchesScreen(),
        overrides: [savedSearchesRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FRA → DYU'), findsOneWidget);
    expect(find.text('BER → LBD'), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete_s1')));
    await tester.pumpAndSettle();

    expect(repo.removed, ['s1']);
    expect(find.text('FRA → DYU'), findsNothing);
    expect(find.text('BER → LBD'), findsOneWidget);
  });

  testWidgets('zeigt Leerzustand ohne Suchen', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const SavedSearchesScreen(),
        overrides: [
          savedSearchesRepositoryProvider.overrideWithValue(_EmptyRepo()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Keine gespeicherten Suchen.'), findsOneWidget);
  });
}

class _EmptyRepo implements SavedSearchesRepository {
  @override
  Future<List<SavedSearch>> list() async => const [];
  @override
  Future<SavedSearch> create({
    String? originAirport,
    String? destinationAirport,
    double? minFreeKg,
  }) => throw UnimplementedError();
  @override
  Future<void> remove(String id) => throw UnimplementedError();
}
