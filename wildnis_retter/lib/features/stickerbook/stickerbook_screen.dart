import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class StickerbookScreen extends ConsumerWidget {
  const StickerbookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final stickers = const ['🦅', '🐺', '🐼', '🦊'];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.stickerbook)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: stickers.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.lightGreen.shade50,
            child: Center(child: Text(stickers[index], style: const TextStyle(fontSize: 28))),
          );
        },
      ),
    );
  }
}