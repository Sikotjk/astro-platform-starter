import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/booking_detail/booking_actions.dart';
import 'package:tj_shipping_app/features/booking_detail/booking_detail_controller.dart';
import 'package:tj_shipping_app/features/booking_detail/booking_detail_repository.dart';
import 'package:tj_shipping_app/features/payments/payment_gateway.dart';
import 'package:tj_shipping_app/models/booking_detail.dart';

class _FakeRepo implements BookingDetailRepository {
  _FakeRepo({this.failAct = false, this.failEscrow = false});
  bool failAct;
  bool failEscrow;
  String status = 'REQUESTED';
  int fetchCount = 0;
  int escrowCount = 0;
  final List<String> actedPaths = [];

  @override
  Future<BookingDetail> fetch(String id) async {
    fetchCount++;
    return BookingDetail(
      id: id,
      status: status,
      paymentStatus: 'PENDING',
      totalAmount: 42,
      currency: 'EUR',
      senderId: 's1',
      travelerId: 't1',
      packageTitle: 'Tee',
      termsAccepted: false,
      events: const [],
    );
  }

  @override
  Future<void> act(String id, String path) async {
    if (failAct) throw Exception('409 ungültiger Übergang');
    actedPaths.add(path);
    status = 'ACCEPTED';
  }

  @override
  Future<String> createEscrow(String id) async {
    escrowCount++;
    if (failEscrow) throw Exception('escrow fehlgeschlagen');
    return 'pi_secret_$id';
  }
}

void main() {
  test('load füllt den State mit der Buchung', () async {
    final c = BookingDetailController(_FakeRepo(), 'b1');
    await c.load();
    expect(c.state.value!.packageTitle, 'Tee');
    expect(c.state.value!.status, 'REQUESTED');
  });

  test('act löst Übergang aus und lädt neu (Erfolg -> null)', () async {
    final repo = _FakeRepo();
    final c = BookingDetailController(repo, 'b1');
    await c.load();

    final err = await c.act(BookingAction.accept);

    expect(err, isNull);
    expect(repo.actedPaths, ['accept']);
    expect(c.state.value!.status, 'ACCEPTED');
  });

  test(
    'act gibt bei Fehler die Meldung zurück, State bleibt erhalten',
    () async {
      final repo = _FakeRepo(failAct: true);
      final c = BookingDetailController(repo, 'b1');
      await c.load();

      final err = await c.act(BookingAction.accept);

      expect(err, isNotNull);
      expect(c.state, isA<AsyncData<BookingDetail>>());
    },
  );

  test('pay: Escrow + Bestätigung -> success, lädt neu', () async {
    final repo = _FakeRepo();
    final gateway = FakePaymentGateway();
    final c = BookingDetailController(repo, 'b1');

    final outcome = await c.pay(gateway);

    expect(outcome.status, PaymentStatus.success);
    expect(repo.escrowCount, 1);
    expect(gateway.confirmedSecrets, ['pi_secret_b1']);
  });

  test('pay: Nutzerabbruch -> cancelled, keine Fehlermeldung', () async {
    final c = BookingDetailController(_FakeRepo(), 'b1');

    final outcome = await c.pay(FakePaymentGateway(cancel: true));

    expect(outcome.status, PaymentStatus.cancelled);
    expect(outcome.error, isNull);
  });

  test('pay: Fehler bei der Bestätigung -> failed mit Meldung', () async {
    final c = BookingDetailController(_FakeRepo(), 'b1');

    final outcome = await c.pay(FakePaymentGateway(fail: true));

    expect(outcome.status, PaymentStatus.failed);
    expect(outcome.error, isNotNull);
  });

  test('pay: Escrow-Fehler -> failed', () async {
    final c = BookingDetailController(_FakeRepo(failEscrow: true), 'b1');

    final outcome = await c.pay(FakePaymentGateway());

    expect(outcome.status, PaymentStatus.failed);
  });
}
