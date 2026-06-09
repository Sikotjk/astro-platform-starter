import 'package:flutter/material.dart';

/// Sterne-Bewertung. Interaktiv, wenn [onChanged] gesetzt ist, sonst nur Anzeige.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 32,
    this.count = 5,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final double size;
  final int count;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [for (var i = 1; i <= count; i++) _star(context, i, color)],
    );
  }

  Widget _star(BuildContext context, int i, Color color) {
    final filled = i <= value;
    final icon = Icon(
      filled ? Icons.star : Icons.star_border,
      size: size,
      color: color,
    );
    if (onChanged == null) return icon;
    return IconButton(
      key: Key('star_$i'),
      iconSize: size,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: icon,
      onPressed: () => onChanged!(i),
    );
  }
}
