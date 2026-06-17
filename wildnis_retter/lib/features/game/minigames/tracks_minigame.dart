import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class TracksMinigame extends StatefulWidget {
  const TracksMinigame({super.key});

  @override
  State<TracksMinigame> createState() => _TracksMinigameState();
}

class _TracksMinigameState extends State<TracksMinigame> {
  int _correctIndex = 1;
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tracksMinigame)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(l10n.tracksMinigame),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: List.generate(3, (index) {
                final isCorrect = index == _correctIndex;
                final isSelected = _selectedIndex == index;
                return ChoiceChip(
                  label: Text('Spur ${index + 1}'),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedIndex = index);
                    if (isCorrect) {
                      _showSuccess(context);
                    }
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context) {
    final l10n = L10n.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.congratsRescue),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}