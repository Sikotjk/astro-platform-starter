import 'dart:typed_data';

/// Abstraktion über das Anzeigen/Teilen des PDF (hält die UI testbar).
abstract class ManifestViewer {
  Future<void> present(Uint8List bytes, {required String filename});
}

/// Test-/Dev-Implementierung: protokolliert die Aufrufe.
class FakeManifestViewer implements ManifestViewer {
  final List<int> presentedSizes = [];

  @override
  Future<void> present(Uint8List bytes, {required String filename}) async {
    presentedSizes.add(bytes.lengthInBytes);
  }
}
