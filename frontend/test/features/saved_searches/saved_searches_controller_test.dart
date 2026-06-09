import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/saved_searches/saved_searches_controller.dart';
import 'package:tj_shipping_app/features/saved_searches/saved_searches_repository.dart';
import 'package:tj_shipping_app/models/saved_search.dart';

class _FakeRepo implements SavedSearchesRepository {
  _FakeRepo({this.failRemove = false});
  bool failRemove;
  final List<SavedSearch> items = [
    const SavedSearch(
      id: 's1',
      originAirport: 'FRA',
      destinationAirport: 'DYU',
    ),
  ];
  Map<String, dynamic>? lastCreate;

  @override
  Future<List<SavedSearch>> list() async => List.unmodifiable(items);

  @override
  Future<SavedSearch> create({
    String? originAirport,
    String? destinationAirport,
    double? minFreeKg,
  }) async {
    lastCreate = {
      'originAirport': originAirport,
      'destinationAirport': destinationAirport,
      'minFreeKg': minFreeKg,
    };
    final s = SavedSearch(
      id: 's2',
      originAirport: originAirport,
      destinationAirport: destinationAirport,
      minFreeKg: minFreeKg,
    );
    items.add(s);
    return s;
  }

  @override
  Future<void> remove(String id) async {
    if (failRemove) throw Exception('500');
    items.removeWhere((s) => s.id == id);
  }
}

void main() {
  test('load füllt die Liste', () async {
    final c = SavedSearchesController(_FakeRepo());
    await c.load();
    expect(c.state.value, hasLength(1));
    expect(c.state.value!.first.route, 'FRA → DYU');
  });

  test('create reicht Felder durch und lädt neu', () async {
    final repo = _FakeRepo();
    final c = SavedSearchesController(repo);
    await c.load();

    final err = await c.create(
      originAirport: 'fra',
      destinationAirport: 'dyu',
      minFreeKg: 5,
    );

    expect(err, isNull);
    expect(repo.lastCreate, {
      'originAirport': 'fra',
      'destinationAirport': 'dyu',
      'minFreeKg': 5.0,
    });
    expect(c.state.value, hasLength(2));
  });

  test('remove (Erfolg) entfernt optimistisch', () async {
    final c = SavedSearchesController(_FakeRepo());
    await c.load();

    final err = await c.remove('s1');

    expect(err, isNull);
    expect(c.state.value, isEmpty);
  });

  test(
    'remove (Fehler) macht das optimistische Entfernen rückgängig',
    () async {
      final c = SavedSearchesController(_FakeRepo(failRemove: true));
      await c.load();

      final err = await c.remove('s1');

      expect(err, isNotNull);
      expect(c.state.value, hasLength(1)); // Rollback
    },
  );
}
