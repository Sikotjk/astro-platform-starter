import { describe, it, expect, beforeEach } from 'vitest';
import { BookingService, BookingStateError } from './booking.service';
import { InMemoryBookingRepository } from './in-memory.repository';
import { FakePaymentGateway } from '../payments/fake.gateway';
import type { BookingRecord } from './booking.repository';

function makeBooking(over: Partial<BookingRecord> = {}): BookingRecord {
  return {
    id: 'bk_1',
    status: 'REQUESTED',
    senderId: 'u_sender',
    travelerId: 'u_traveler',
    itemPriceMinor: 10000, // 100,00 € Traveler-Anteil
    serviceFeeMinor: 1500, //  15,00 € Plattform
    totalAmountMinor: 11500, // 115,00 € gesamt
    currency: 'EUR',
    paymentIntentId: null,
    transferId: null,
    paymentStatus: 'PENDING',
    customsDeclared: false,
    travelerAcceptedTerms: false,
    senderStripeCustomerId: 'cus_123',
    travelerStripeAccountId: 'acct_123',
    ...over,
  };
}

let repo: InMemoryBookingRepository;
let gateway: FakePaymentGateway;
let service: BookingService;

beforeEach(() => {
  repo = new InMemoryBookingRepository();
  gateway = new FakePaymentGateway();
  service = new BookingService(repo, gateway, 0.15);
});

describe('Vollständiger Happy-Path-Flow inkl. Escrow', () => {
  it('durchläuft REQUESTED → CONFIRMED und zahlt korrekt aus', async () => {
    repo.seed(makeBooking());

    // Traveler akzeptiert
    await service.transition('bk_1', 'ACCEPTED', 'TRAVELER');

    // Escrow anlegen -> PaymentIntent erstellt, Status bleibt ACCEPTED
    const { clientSecret } = await service.createEscrow('bk_1');
    expect(clientSecret).toContain('secret');
    expect(gateway.countOf('createEscrow')).toBe(1);
    expect((await repo.findById('bk_1'))!.status).toBe('ACCEPTED');

    // Stripe-Webhook bestätigt Zahlung -> PAID, Escrow gehalten
    const pi = (await repo.findById('bk_1'))!.paymentIntentId!;
    await service.handlePaymentSucceeded('evt_1', pi);
    let b = (await repo.findById('bk_1'))!;
    expect(b.status).toBe('PAID');
    expect(b.paymentStatus).toBe('ESCROW_HELD');

    // Compliance-Gate erfüllen, dann Übergabe
    repo.seed({ ...b, customsDeclared: true, travelerAcceptedTerms: true });
    await service.transition('bk_1', 'HANDED_OVER', 'SENDER');
    await service.transition('bk_1', 'IN_TRANSIT', 'TRAVELER');
    await service.transition('bk_1', 'DELIVERED', 'TRAVELER');

    // Sender bestätigt -> Auszahlung an Traveler (nur itemPrice!)
    await service.transition('bk_1', 'CONFIRMED', 'SENDER');
    b = (await repo.findById('bk_1'))!;
    expect(b.status).toBe('CONFIRMED');
    expect(b.paymentStatus).toBe('RELEASED');
    expect(b.transferId).toMatch(/^tr_fake_/);

    // Es wurde genau der Traveler-Anteil ausgezahlt, serviceFee blieb bei Plattform.
    const release = gateway.calls.find((c) => c.type === 'releaseEscrow');
    expect(release!.amountMinor).toBe(10000);
    expect(gateway.countOf('releaseEscrow')).toBe(1);
  });
});

describe('Compliance-Gate im Service', () => {
  it('blockt HANDED_OVER ohne Zoll-Deklaration', async () => {
    repo.seed(
      makeBooking({ status: 'PAID', paymentStatus: 'ESCROW_HELD', paymentIntentId: 'pi_x' }),
    );
    await expect(service.transition('bk_1', 'HANDED_OVER', 'SENDER')).rejects.toThrow(
      /Zoll-Deklaration/,
    );
  });
});

describe('Webhook-Idempotenz', () => {
  it('verarbeitet dasselbe Event nicht zweimal', async () => {
    repo.seed(makeBooking({ status: 'ACCEPTED', paymentIntentId: 'pi_dup' }));

    const first = await service.handlePaymentSucceeded('evt_dup', 'pi_dup');
    const second = await service.handlePaymentSucceeded('evt_dup', 'pi_dup');

    expect(first.processed).toBe(true);
    expect(second.processed).toBe(false);
    // Nur EIN Statuswechsel nach PAID im Audit-Log.
    expect(repo.events.filter((e) => e.toStatus === 'PAID')).toHaveLength(1);
  });
});

describe('Refund-Pfad', () => {
  it('erstattet den Sender bei Storno nach Zahlung (PAID → CANCELLED)', async () => {
    repo.seed(
      makeBooking({ status: 'PAID', paymentStatus: 'ESCROW_HELD', paymentIntentId: 'pi_r' }),
    );

    const b = await service.transition('bk_1', 'CANCELLED', 'SENDER');
    expect(b.status).toBe('CANCELLED');
    expect(b.paymentStatus).toBe('REFUNDED');
    expect(gateway.countOf('refund')).toBe(1);
  });

  it('macht keinen Stripe-Refund, wenn nie Escrow gehalten wurde (ACCEPTED → CANCELLED)', async () => {
    repo.seed(makeBooking({ status: 'ACCEPTED' }));
    await service.transition('bk_1', 'CANCELLED', 'TRAVELER');
    expect(gateway.countOf('refund')).toBe(0);
  });
});

describe('Doppel-Auszahlung verhindern', () => {
  it('lehnt erneute Freigabe nach RELEASED ab', async () => {
    repo.seed(
      makeBooking({
        status: 'DELIVERED',
        paymentStatus: 'RELEASED',
        paymentIntentId: 'pi_done',
        transferId: 'tr_done',
        customsDeclared: true,
        travelerAcceptedTerms: true,
      }),
    );
    await expect(service.transition('bk_1', 'CONFIRMED', 'SENDER')).rejects.toThrow(
      BookingStateError,
    );
  });
});

describe('Audit-Log', () => {
  it('protokolliert jeden Statuswechsel append-only', async () => {
    repo.seed(makeBooking());
    await service.transition('bk_1', 'ACCEPTED', 'TRAVELER');
    await service.createEscrow('bk_1'); // reiner Patch -> kein Event
    expect(repo.events).toHaveLength(1);
    expect(repo.events[0]).toMatchObject({
      fromStatus: 'REQUESTED',
      toStatus: 'ACCEPTED',
      triggeredBy: 'TRAVELER',
    });
  });
});
