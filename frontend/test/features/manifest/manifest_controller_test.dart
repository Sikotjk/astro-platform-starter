import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
  test('load lädt PDF + reicht Locale durch', () async {
    final repo = _FakeManifestRepo();
    final c = ManifestController(repo, 'b1', 'ru');

    await c.load();

    expect(c.state.hasValue, isTrue);
    expect(c.state.value!.hash, 'abc123');
    expect(c.state.value!.sizeKb, 2);
    expect(repo.lastLocale, 'ru');
  });

  test('Fehler (z.B. 409) -> error-State', () async {
    final c = ManifestController(_FakeManifestRepo(fail: true), 'b1', 'de');

    await c.load();

    expect(c.state, isA<AsyncError<ManifestPdf>>());
  });
}
