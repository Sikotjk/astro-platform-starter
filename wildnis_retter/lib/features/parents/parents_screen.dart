import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class ParentsScreen extends ConsumerStatefulWidget {
  const ParentsScreen({super.key});

  @override
  ConsumerState<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends ConsumerState<ParentsScreen> {
  double _minutesPerDay = 30;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.parentsArea)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.timeLimit, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('${l10n.minutesPerDay}: ${_minutesPerDay.round()}'),
            Slider(
              min: 10,
              max: 120,
              divisions: 11,
              value: _minutesPerDay,
              onChanged: (v) => setState(() => _minutesPerDay = v),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.save)),
                );
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}