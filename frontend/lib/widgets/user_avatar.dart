import 'package:flutter/material.dart';

/// Rundes Profilbild. Zeigt das Bild aus [url]; fehlt es oder lädt es nicht,
/// wird der erste Buchstabe von [name] als Fallback gezeigt.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.url, this.radius = 20});

  final String name;
  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = (trimmed.isNotEmpty ? trimmed[0] : '?').toUpperCase();
    final hasUrl = url != null && url!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      // foregroundImage fällt bei null/Ladefehler automatisch auf child zurück.
      foregroundImage: hasUrl ? NetworkImage(url!) : null,
      child: Text(initial, style: TextStyle(fontSize: radius * 0.8)),
    );
  }
}
