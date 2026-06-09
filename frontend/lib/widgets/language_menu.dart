import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n_ext.dart';
import '../core/locale_controller.dart';

/// Sprachauswahl als AppBar-Aktion. Zeigt die kurzen Codes DE/RU/TJ
/// (Tadschikisch nutzt intern den ISO-Sprachcode `tg`, angezeigt wird `TJ`).
class LanguageMenu extends ConsumerWidget {
  const LanguageMenu({super.key});

  static const _options = [('de', 'DE'), ('ru', 'RU'), ('tg', 'TJ')];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider).languageCode;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: context.l10n.language,
      onSelected: (code) => ref.read(localeProvider.notifier).setLanguage(code),
      itemBuilder: (context) => [
        for (final (code, label) in _options)
          PopupMenuItem(
            value: code,
            child: Row(
              children: [
                if (code == current)
                  const Icon(Icons.check, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
          ),
      ],
    );
  }
}
