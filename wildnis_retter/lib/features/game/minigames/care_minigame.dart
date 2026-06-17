import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class CareMinigame extends StatefulWidget {
  const CareMinigame({super.key});

  @override
  State<CareMinigame> createState() => _CareMinigameState();
}

class _CareMinigameState extends State<CareMinigame> {
  bool bandaged = false;
  bool cleaned = false;
  bool fed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.careMinigame)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _draggable('🩹', () => setState(() => bandaged = true)),
                _draggable('🧼', () => setState(() => cleaned = true)),
                _draggable('🍎', () => setState(() => fed = true)),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: DragTarget<String>(
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.lightGreen.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '${bandaged ? '🩹' : ' '}${cleaned ? '🧼' : ' '}${fed ? '🍎' : ' '}\n${l10n.careMinigame}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  );
                },
                onAccept: (_) {
                  if (bandaged && cleaned && fed) {
                    _showSuccess(context);
                  }
                },
                onWillAccept: (_) => true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Draggable<String> _draggable(String emoji, VoidCallback onDropped) {
    return Draggable<String>(
      data: emoji,
      feedback: Material(color: Colors.transparent, child: Text(emoji, style: const TextStyle(fontSize: 32))),
      child: Text(emoji, style: const TextStyle(fontSize: 32)),
      childWhenDragging: const Opacity(opacity: 0.3, child: Text(' ', style: TextStyle(fontSize: 32))),
      onDragEnd: (details) => onDropped(),
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