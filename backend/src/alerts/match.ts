// Pure, framework-unabhängige Match-Logik: passt ein neuer Trip zu einer
// gespeicherten Suche? Alle gesetzten Kriterien müssen erfüllt sein (UND).

export interface TripView {
  originAirport: string;
  destinationAirport: string;
  departureAt: Date;
  freeKg: number;
}

export interface SavedSearchView {
  originAirport?: string | null;
  destinationAirport?: string | null;
  departureFrom?: Date | null;
  departureTo?: Date | null;
  minFreeKg?: number | null;
  active: boolean;
}

export function tripMatchesSearch(trip: TripView, search: SavedSearchView): boolean {
  if (!search.active) return false;

  if (search.originAirport && search.originAirport.toUpperCase() !== trip.originAirport) {
    return false;
  }
  if (
    search.destinationAirport &&
    search.destinationAirport.toUpperCase() !== trip.destinationAirport
  ) {
    return false;
  }
  if (search.departureFrom && trip.departureAt < search.departureFrom) return false;
  if (search.departureTo && trip.departureAt > search.departureTo) return false;
  if (search.minFreeKg != null && trip.freeKg < search.minFreeKg) return false;

  return true;
}
