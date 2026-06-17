class Animal {
  Animal({required this.id, required this.nameKey, required this.emoji});
  final String id; // e.g., 'eagle'
  final String nameKey; // l10n key
  final String emoji; // placeholder icon
}

class Mission {
  Mission({required this.id, required this.animalId, required this.title});
  final String id;
  final String animalId;
  final String title;
}

class Sticker {
  Sticker({required this.id, required this.animalId, required this.emoji});
  final String id;
  final String animalId;
  final String emoji;
}