import 'package:flutter/material.dart';

import '../core/l10n_ext.dart';
import '../core/theme/app_theme.dart';

/// Zeigt eine dezente „Aktualisiert"-Bestätigung (kurzer Floating-SnackBar mit
/// Häkchen in der Erfolgsfarbe). Nur aufrufen, wenn das Neuladen erfolgreich
/// war — vereinheitlicht das Feedback aller Pull-to-Refresh-Listen.
void showRefreshedToast(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1100),
      backgroundColor: AppColors.success,
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              context.l10n.refreshed,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
