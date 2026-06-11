// Port für die PDF-Erzeugung des Zoll-Manifests. Hält den Service unabhängig
// von der konkreten Render-Bibliothek (pdfkit).

import type { Manifest } from '../customs/manifest';
import type { Locale } from '../customs/customs.types';

export interface ManifestPdfRenderer {
  /** Rendert das Manifest als PDF und liefert die Bytes. */
  render(manifest: Manifest, locale: Locale): Promise<Buffer>;
}
