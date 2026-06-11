import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/manifest/manifest_cache.dart';
import 'package:tj_shipping_app/features/manifest/manifest_controller.dart';
import 'package:tj_shipping_app/features/manifest/manifest_repository.dart';

class _FakeManifestRepo implements ManifestRepository {
  _FakeManifestRepo({this.fail = false});
  bool fail;
  String? lastLocale;

  @override
  Future<ManifestPdf> fetch(String bookingId, {String locale = 'de'}) async {
    lastLocale = locale;
    if (fail) throw Exception('409 noch nicht verfügbar');
    return ManifestPdf(
      bytes: Uint8List.fromList(List.filled(2048, 1)),
      hash: 'abc123',
    );
  }
}

void main() {
  test('load lädt PDF, reicht Locale durch und füllt den Cache', () async {
    final repo = _FakeManifestRepo();
    final cache = InMemoryManifestCache();
    final c = ManifestController(repo, cache, 'b1', 'ru');

    await c.load();

    expect(c.state.hasValue, isTrue);
    expect(c.state.value!.hash, 'abc123');
    expect(c.state.value!.sizeKb, 2);
    expect(c.state.value!.fromCache, isFalse);
    expect(repo.lastLocale, 'ru');
    // Offline-Kopie wurde abgelegt.
    expect(await cache.read('b1'), isNotNull);
  });

  test('Netzfehler MIT Offline-Kopie -> zeigt die gecachte Version', () async {
    final cache = InMemoryManifestCache();
    await cache.save(
      'b1',
      ManifestPdf(bytes: Uint8List.fromList([1, 2, 3]), hash: 'old'),
    );
    final c = ManifestController(
      _FakeManifestRepo(fail: true),
      cache,
      'b1',
      'de',
    );

    await c.load();

    expect(c.state.hasValue, isTrue);
    expect(c.state.value!.fromCache, isTrue);
    expect(c.state.value!.hash, 'old');
  });

  test('Netzfehler OHNE Offline-Kopie -> error-State', () async {
    final c = ManifestController(
      _FakeManifestRepo(fail: true),
      InMemoryManifestCache(),
      'b1',
      'de',
    );

    await c.load();

    expect(c.state, isA<AsyncError<ManifestPdf>>());
  });
}
