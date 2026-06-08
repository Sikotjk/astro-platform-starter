import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n_ext.dart';
import '../core/locale_controller.dart';

/// Sprachauswahl (DE/RU/TG) als AppBar-Aktion.
class LanguageMenu extends ConsumerWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: l10n.language,
      onSelected: (code) => ref.read(localeProvider.notifier).setLanguage(code),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'de', child: Text(l10n.langDe)),
        PopupMenuItem(value: 'ru', child: Text(l10n.langRu)),
        PopupMenuItem(value: 'tg', child: Text(l10n.langTg)),
      ],
    );
  }
}
