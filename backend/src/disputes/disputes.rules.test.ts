import { describe, it, expect } from 'vitest';
import { resolutionToBookingStatus, resolutionToDisputeStatus } from './disputes.rules';

describe('Dispute-Auflösung', () => {
  it('REFUND -> Booking REFUNDED, Dispute RESOLVED_REFUND', () => {
    expect(resolutionToBookingStatus('REFUND')).toBe('REFUNDED');
    expect(resolutionToDisputeStatus('REFUND')).toBe('RESOLVED_REFUND');
  });

  it('RELEASE -> Booking CONFIRMED, Dispute RESOLVED_RELEASE', () => {
    expect(resolutionToBookingStatus('RELEASE')).toBe('CONFIRMED');
    expect(resolutionToDisputeStatus('RELEASE')).toBe('RESOLVED_RELEASE');
  });
});
