import 'package:flutter/material.dart';

/// Dezente Eintritts-Animation (Fade + sanftes Hochgleiten) für Listen- und
/// Grid-Elemente. Implizit über [TweenAnimationBuilder] umgesetzt — läuft einmal
/// beim ersten Build und hinterlässt keine offenen Timer (testfreundlich).
///
/// [index] staffelt den Effekt leicht über die Dauer, sodass Elemente
/// nacheinander erscheinen (ohne verzögerte Timer).
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.offsetY = 14,
  });

  final Widget child;
  final int index;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    // Spätere Elemente animieren minimal länger -> wirkt gestaffelt.
    final ms = 260 + (index.clamp(0, 8)) * 55;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * offsetY),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
