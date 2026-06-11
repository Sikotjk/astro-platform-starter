import 'package:flutter/material.dart';

/// Rundes Profilbild. Zeigt das Bild aus [url]; fehlt es oder lädt es nicht,
/// wird der erste Buchstabe von [name] auf einer namensabhängigen Farbe gezeigt.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.url, this.radius = 20});

  final String name;
  final String? url;
  final double radius;

  // Dezente, harmonische Farbpalette für Initialen-Avatare.
  static const _palette = [
    Color(0xFF0E6E62),
    Color(0xFF0A4A63),
    Color(0xFFC9842A),
    Color(0xFF3E78B2),
    Color(0xFF6A4C93),
    Color(0xFF2E9E5B),
  ];

  Color _colorFor(String s) {
    if (s.isEmpty) return _palette.first;
    final hash = s.codeUnits.fold<int>(0, (a, c) => a + c);
    return _palette[hash % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = (trimmed.isNotEmpty ? trimmed[0] : '?').toUpperCase();
    final hasUrl = url != null && url!.isNotEmpty;
    final color = _colorFor(trimmed);

    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.18),
      // foregroundImage fällt bei null/Ladefehler automatisch auf child zurück.
      foregroundImage: hasUrl ? NetworkImage(url!) : null,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
