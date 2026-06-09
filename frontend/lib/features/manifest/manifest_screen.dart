import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import 'manifest_repository.dart';

class ManifestScreen extends ConsumerWidget {
  const ManifestScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(manifestControllerProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manifestTitle)),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              e.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
        data: (pdf) => _ManifestReady(bookingId: bookingId, pdf: pdf),
      ),
    );
  }
}

class _ManifestReady extends ConsumerWidget {
  const _ManifestReady({required this.bookingId, required this.pdf});

  final String bookingId;
  final ManifestPdf pdf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.picture_as_pdf,
                size: 72,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text('${l10n.manifestTitle} · ${l10n.manifestSize(pdf.sizeKb)}'),
              if (pdf.hash != null) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.manifestHashLabel,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                SelectableText(
                  pdf.hash!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('openManifest'),
                onPressed: () => ref
                    .read(manifestViewerProvider)
                    .present(pdf.bytes, filename: 'manifest-$bookingId.pdf'),
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.manifestOpen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
