import { describe, it, expect } from 'vitest';
import { resolveReviewTarget, nextRatingAggregate, ReviewError } from './reviews.rules';
import type { ReviewableBooking } from './reviews.rules';

const b = (status: ReviewableBooking['status']): ReviewableBooking => ({
  senderId: 's1',
  travelerId: 't1',
  status,
});

describe('resolveReviewTarget', () => {
  it('Sender bewertet Traveler und umgekehrt', () => {
    expect(resolveReviewTarget('s1', b('CONFIRMED'))).toBe('t1');
    expect(resolveReviewTarget('t1', b('CONFIRMED'))).toBe('s1');
  });
  it('verbietet Bewertung vor Abschluss', () => {
    expect(() => resolveReviewTarget('s1', b('DELIVERED'))).toThrow(/CONFIRMED/);
  });
  it('verbietet Unbeteiligte', () => {
    expect(() => resolveReviewTarget('x', b('CONFIRMED'))).toThrow(ReviewError);
  });
});

describe('nextRatingAggregate', () => {
  it('berechnet den ersten Durchschnitt', () => {
    expect(nextRatingAggregate({ ratingAvg: 0, ratingCount: 0 }, 5)).toEqual({
      ratingAvg: 5,
      ratingCount: 1,
    });
  });
  it('mittelt korrekt und rundet auf 2 Stellen', () => {
    const r = nextRatingAggregate({ ratingAvg: 4, ratingCount: 2 }, 5); // (4+4+5)/3 = 4.333
    expect(r).toEqual({ ratingAvg: 4.33, ratingCount: 3 });
  });
});
