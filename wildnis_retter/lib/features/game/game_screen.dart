import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import 'minigames/tracks_minigame.dart';
import 'minigames/care_minigame.dart';
import 'minigames/release_minigame.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  String _selectedAnimal = 'eagle';

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mission)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.chooseAnimal, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final animal in const ['eagle', 'wolf', 'panda', 'fox'])
                  ChoiceChip(
                    selected: _selectedAnimal == animal,
                    onSelected: (_) => setState(() => _selectedAnimal = animal),
                    label: Text(_animalName(l10n, animal)),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _MinigameTile(title: l10n.tracksMinigame, onTap: () => _open(context, const TracksMinigame())),
            _MinigameTile(title: l10n.careMinigame, onTap: () => _open(context, const CareMinigame())),
            _MinigameTile(title: l10n.releaseMinigame, onTap: () => _open(context, const ReleaseMinigame())),
          ],
        ),
      ),
    );
  }

  String _animalName(L10n l10n, String key) {
    switch (key) {
      case 'eagle':
        return l10n.animalsEagle;
      case 'wolf':
        return l10n.animalsWolf;
      case 'panda':
        return l10n.animalsPanda;
      case 'fox':
        return l10n.animalsFox;
      default:
        return key;
    }
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _MinigameTile extends StatelessWidget {
  const _MinigameTile({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}