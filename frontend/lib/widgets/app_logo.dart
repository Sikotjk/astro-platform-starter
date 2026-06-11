import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Markenzeichen: ein abgerundetes Quadrat mit Verlauf und Flug-/Paket-Symbol.
/// Optional mit Wortmarke daneben.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 44,
    this.showWordmark = false,
    this.wordmark = 'TJ-Shipping',
    this.onDark = false,
  });

  final double size;
  final bool showWordmark;
  final String wordmark;

  /// Wortmarke in Weiß (für dunkle/gefärbte Hintergründe).
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.35),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Icon(
        Icons.local_shipping_rounded,
        color: Colors.white,
        size: size * 0.56,
      ),
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.3),
        Text(
          wordmark,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: onDark ? Colors.white : null,
          ),
        ),
      ],
    );
  }
}
