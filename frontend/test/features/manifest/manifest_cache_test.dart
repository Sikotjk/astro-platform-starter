import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/manifest/manifest_cache.dart';
import 'package:tj_shipping_app/features/manifest/manifest_repository.dart';

void main() {
  late Directory tmp;
  late FileManifestCache cache;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('manifest_cache_test');
    cache = FileManifestCache(directoryProvider: () async => tmp);
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  test('save + read liefert Bytes und Hash als Offline-Kopie', () async {
    final pdf = ManifestPdf(
      bytes: Uint8List.fromList([1, 2, 3, 4]),
      hash: 'deadbeef',
    );

    await cache.save('b1', pdf);
    final restored = await cache.read('b1');

    expect(restored, isNotNull);
    expect(restored!.bytes, [1, 2, 3, 4]);
    expect(restored.hash, 'deadbeef');
    expect(restored.fromCache, isTrue);
  });

  test('read ohne gespeicherte Kopie -> null', () async {
    expect(await cache.read('unknown'), isNull);
  });

  test('save ohne Hash -> read liefert hash null', () async {
    await cache.save('b2', ManifestPdf(bytes: Uint8List.fromList([9])));
    final restored = await cache.read('b2');
    expect(restored!.hash, isNull);
  });
}
