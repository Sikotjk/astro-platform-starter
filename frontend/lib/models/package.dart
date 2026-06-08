/// Ein Posten der Zoll-Deklaration (Eingabe beim Paket-Anlegen).
class DeclarationItemInput {
  const DeclarationItemInput({
    required this.category,
    required this.description,
    required this.quantity,
    required this.unitValueEur,
    this.isSealed = false,
  });

  final String category;
  final String description;
  final int quantity;
  final double unitValueEur;
  final bool isSealed;

  Map<String, dynamic> toJson() => {
    'category': category,
    'description': description,
    'quantity': quantity,
    'unitValueEur': unitValueEur,
    'isSealed': isSealed,
  };
}

/// Anfrage zum Anlegen eines Pakets (POST /packages).
class CreatePackageRequest {
  const CreatePackageRequest({
    required this.title,
    required this.weightKg,
    required this.declaredValueEur,
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientCity,
    required this.items,
  });

  final String title;
  final double weightKg;
  final double declaredValueEur;
  final String recipientName;
  final String recipientPhone;
  final String recipientCity;
  final List<DeclarationItemInput> items;

  Map<String, dynamic> toJson() => {
    'title': title,
    'weightKg': weightKg,
    'declaredValueEur': declaredValueEur,
    'recipientName': recipientName,
    'recipientPhone': recipientPhone,
    'recipientCity': recipientCity,
    'items': items.map((i) => i.toJson()).toList(),
  };
}

/// Verfügbare Zoll-Kategorien (Spiegel des Backend-Enums).
const customsCategories = <String>[
  'DOCUMENTS',
  'CLOTHING',
  'FOOD_DRY',
  'ELECTRONICS',
  'MEDICINE',
  'GIFTS',
  'COSMETICS',
  'OTHER',
];
