import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'manifest_repository.dart';

/// Lokaler Cache für das Zoll-Manifest: Der Traveler muss das Dokument am
/// Zoll auch OHNE Netz (kein Roaming) vorzeigen können.
abstract class ManifestCache {
  Future<void> save(String bookingId, ManifestPdf pdf);
  Future<ManifestPdf?> read(String bookingId);
}

/// Persistiert PDF + Hash im App-Dokumentenverzeichnis.
class FileManifestCache implements ManifestCache {
  FileManifestCache({Future<Directory> Function()? directoryProvider})
    : _directoryProvider =
          directoryProvider ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _directoryProvider;

  Future<File> _pdfFile(String bookingId) async {
    final dir = await _directoryProvider();
    return File('${dir.path}/manifest_$bookingId.pdf');
  }

  Future<File> _hashFile(String bookingId) async {
    final dir = await _directoryProvider();
    return File('${dir.path}/manifest_$bookingId.hash');
  }

  @override
  Future<void> save(String bookingId, ManifestPdf pdf) async {
    await (await _pdfFile(bookingId)).writeAsBytes(pdf.bytes, flush: true);
    final hash = pdf.hash;
    if (hash != null) {
      await (await _hashFile(bookingId)).writeAsString(hash, flush: true);
    }
  }

  @override
  Future<ManifestPdf?> read(String bookingId) async {
    final file = await _pdfFile(bookingId);
    if (!await file.exists()) return null;
    final bytes = Uint8List.fromList(await file.readAsBytes());
    final hashFile = await _hashFile(bookingId);
    final hash = await hashFile.exists() ? await hashFile.readAsString() : null;
    return ManifestPdf(bytes: bytes, hash: hash, fromCache: true);
  }
}

/// Test-/Dev-Implementierung ohne Dateisystem.
class InMemoryManifestCache implements ManifestCache {
  final Map<String, ManifestPdf> _store = {};

  @override
  Future<void> save(String bookingId, ManifestPdf pdf) async {
    _store[bookingId] = pdf;
  }

  @override
  Future<ManifestPdf?> read(String bookingId) async {
    final pdf = _store[bookingId];
    if (pdf == null) return null;
    return ManifestPdf(bytes: pdf.bytes, hash: pdf.hash, fromCache: true);
  }
}
