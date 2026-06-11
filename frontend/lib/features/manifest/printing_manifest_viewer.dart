import 'dart:typed_data';

import 'package:printing/printing.dart';

import 'manifest_viewer.dart';

/// Reale Implementierung: öffnet den plattformübergreifenden Druck-/Teilen-
/// Dialog (funktioniert auch im Web).
class PrintingManifestViewer implements ManifestViewer {
  const PrintingManifestViewer();

  @override
  Future<void> present(Uint8List bytes, {required String filename}) {
    return Printing.sharePdf(bytes: bytes, filename: filename);
  }
}
