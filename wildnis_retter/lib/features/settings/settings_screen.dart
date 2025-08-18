import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../parents/parents_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _language = 'de';

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: Text(l10n.language)),
          DropdownButton<String>(
            value: _language,
            items: [
              DropdownMenuItem(value: 'de', child: Text(l10n.de)),
              DropdownMenuItem(value: 'ru', child: Text(l10n.ru)),
              DropdownMenuItem(value: 'tg', child: Text(l10n.tg)),
            ],
            onChanged: (v) => setState(() => _language = v ?? 'de'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ParentsScreen()),
              );
            },
            child: Text(l10n.parentsArea),
          ),
        ],
      ),
    );
  }
}