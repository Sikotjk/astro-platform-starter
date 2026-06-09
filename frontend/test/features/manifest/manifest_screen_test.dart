import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/providers.dart';
import 'package:tj_shipping_app/features/manifest/manifest_repository.dart';
import 'package:tj_shipping_app/features/manifest/manifest_screen.dart';
import 'package:tj_shipping_app/features/manifest/manifest_viewer.dart';

import '../../support/localized_app.dart';

class _FakeManifestRepo implements ManifestRepository {
  _FakeManifestRepo({this.fail = false});
  bool fail;

  @override
  Future<ManifestPdf> fetch(String bookingId, {String locale = 'de'}) async {
    if (fail) {
      // Simuliert die 409-Antwort des Backends (DioException mit Message).
      final req = RequestOptions(path: '/bookings/$bookingId/manifest');
      throw DioException(
        requestOptions: req,
        response: Response(
          requestOptions: req,
          statusCode: 409,
          data: {'message': 'Traveler hat noch nicht bestätigt.'},
        ),
      );
    }
    return ManifestPdf(
      bytes: Uint8List.fromList(List.filled(1500, 7)),
      hash: 'deadbeef',
    );
  }
}

void main() {
  testWidgets('zeigt geladenes Manifest mit Hash + Öffnen-Button', (
    tester,
  ) async {
    final viewer = FakeManifestViewer();
    await tester.pumpWidget(
      localizedApp(
        const ManifestScreen(bookingId: 'b1'),
        overrides: [
          manifestRepositoryProvider.overrideWithValue(_FakeManifestRepo()),
          manifestViewerProvider.overrideWithValue(viewer),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('deadbeef'), findsOneWidget);
    expect(find.byKey(const Key('openManifest')), findsOneWidget);

    await tester.tap(find.byKey(const Key('openManifest')));
    await tester.pump();
    expect(viewer.presentedSizes, isNotEmpty);
  });

  testWidgets('zeigt Fehlermeldung, wenn Manifest nicht verfügbar', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedApp(
        const ManifestScreen(bookingId: 'b1'),
        overrides: [
          manifestRepositoryProvider.overrideWithValue(
            _FakeManifestRepo(fail: true),
          ),
          manifestViewerProvider.overrideWithValue(FakeManifestViewer()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('bestätigt'), findsOneWidget);
  });
}
