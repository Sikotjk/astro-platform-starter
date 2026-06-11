import { describe, it, expect } from 'vitest';
import { tripMatchesSearch, type TripView, type SavedSearchView } from './match';

const trip: TripView = {
  originAirport: 'FRA',
  destinationAirport: 'DYU',
  departureAt: new Date('2026-09-01T10:00:00Z'),
  freeKg: 10,
};

const search = (over: Partial<SavedSearchView> = {}): SavedSearchView => ({
  active: true,
  ...over,
});

describe('tripMatchesSearch', () => {
  it('leere (aber aktive) Suche matcht jeden Trip', () => {
    expect(tripMatchesSearch(trip, search())).toBe(true);
  });

  it('inaktive Suche matcht nie', () => {
    expect(tripMatchesSearch(trip, search({ active: false }))).toBe(false);
  });

  it('matcht auf Route (case-insensitiv)', () => {
    expect(
      tripMatchesSearch(trip, search({ originAirport: 'fra', destinationAirport: 'dyu' })),
    ).toBe(true);
    expect(tripMatchesSearch(trip, search({ originAirport: 'MUC' }))).toBe(false);
    expect(tripMatchesSearch(trip, search({ destinationAirport: 'IST' }))).toBe(false);
  });

  it('respektiert das Datumsfenster', () => {
    expect(tripMatchesSearch(trip, search({ departureFrom: new Date('2026-08-01') }))).toBe(true);
    expect(tripMatchesSearch(trip, search({ departureTo: new Date('2026-08-15') }))).toBe(false);
    expect(
      tripMatchesSearch(
        trip,
        search({ departureFrom: new Date('2026-09-01'), departureTo: new Date('2026-09-30') }),
      ),
    ).toBe(true);
  });

  it('respektiert die Mindest-Restkapazität', () => {
    expect(tripMatchesSearch(trip, search({ minFreeKg: 10 }))).toBe(true);
    expect(tripMatchesSearch(trip, search({ minFreeKg: 12 }))).toBe(false);
    expect(tripMatchesSearch(trip, search({ minFreeKg: 0 }))).toBe(true);
  });

  it('alle Kriterien zusammen (UND-Verknüpfung)', () => {
    expect(
      tripMatchesSearch(
        trip,
        search({
          originAirport: 'FRA',
          destinationAirport: 'DYU',
          minFreeKg: 5,
          departureTo: new Date('2026-09-02'),
        }),
      ),
    ).toBe(true);
    // ein Kriterium verfehlt -> kein Match
    expect(
      tripMatchesSearch(
        trip,
        search({ originAirport: 'FRA', destinationAirport: 'DYU', minFreeKg: 20 }),
      ),
    ).toBe(false);
  });
});
