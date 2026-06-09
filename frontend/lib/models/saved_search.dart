/// Eine gespeicherte Suche (GET /saved-searches).
class SavedSearch {
  const SavedSearch({
    required this.id,
    this.originAirport,
    this.destinationAirport,
    this.minFreeKg,
  });

  final String id;
  final String? originAirport;
  final String? destinationAirport;
  final double? minFreeKg;

  /// "FRA → DYU" bzw. "Überall" für leere Felder.
  String get route =>
      '${originAirport ?? '•••'} → ${destinationAirport ?? '•••'}';

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: json['id'] as String,
      originAirport: json['originAirport'] as String?,
      destinationAirport: json['destinationAirport'] as String?,
      minFreeKg: json['minFreeKg'] != null
          ? double.tryParse(json['minFreeKg'].toString())
          : null,
    );
  }
}
