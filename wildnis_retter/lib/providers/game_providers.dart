import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_models.dart';

final animalsProvider = Provider<List<Animal>>((ref) {
  return [
    Animal(id: 'eagle', nameKey: 'animalsEagle', emoji: '🦅'),
    Animal(id: 'wolf', nameKey: 'animalsWolf', emoji: '🐺'),
    Animal(id: 'panda', nameKey: 'animalsPanda', emoji: '🐼'),
    Animal(id: 'fox', nameKey: 'animalsFox', emoji: '🦊'),
  ];
});

class ProgressState {
  ProgressState({required this.points, required this.stickers});
  final int points;
  final List<Sticker> stickers;

  ProgressState copyWith({int? points, List<Sticker>? stickers}) =>
      ProgressState(points: points ?? this.points, stickers: stickers ?? this.stickers);
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  ProgressNotifier() : super(ProgressState(points: 0, stickers: const []));

  void addPoints(int value) => state = state.copyWith(points: state.points + value);
  void addSticker(Sticker sticker) => state = state.copyWith(stickers: [...state.stickers, sticker]);
}

final progressProvider = StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  return ProgressNotifier();
});