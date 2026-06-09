import '../l10n/app_localizations.dart';

/// Lokalisierte Beschriftung einer Zoll-Kategorie (Spiegel des Backend-Enums).
String customsCategoryLabel(AppLocalizations l10n, String category) {
  return switch (category) {
    'DOCUMENTS' => l10n.categoryDocuments,
    'CLOTHING' => l10n.categoryClothing,
    'FOOD_DRY' => l10n.categoryFoodDry,
    'ELECTRONICS' => l10n.categoryElectronics,
    'MEDICINE' => l10n.categoryMedicine,
    'GIFTS' => l10n.categoryGifts,
    'COSMETICS' => l10n.categoryCosmetics,
    'OTHER' => l10n.categoryOther,
    _ => category,
  };
}
