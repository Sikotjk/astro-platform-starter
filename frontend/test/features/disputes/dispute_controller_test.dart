import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/disputes/dispute_controller.dart';
import 'package:tj_shipping_app/features/disputes/disputes_repository.dart';

class _FakeRepo implements DisputesRepository {
  _FakeRepo({this.fail = false});
  bool fail;
  String? lastReason;

  @override
  Future<void> open(String bookingId, String reason) async {
    if (fail) throw Exception('409 falscher Status');
    lastReason = reason;
  }
}

void main() {
  test(
    'submit (Erfolg) gibt null zurück und reicht die Begründung durch',
    () async {
      final repo = _FakeRepo();
      final c = DisputeController(repo, 'b1');

      final err = await c.submit('Paket beschädigt angekommen');

      expect(err, isNull);
      expect(repo.lastReason, 'Paket beschädigt angekommen');
      expect(c.state, isA<AsyncData<void>>());
    },
  );

  test('submit (Fehler) gibt Meldung zurück und setzt error-State', () async {
    final c = DisputeController(_FakeRepo(fail: true), 'b1');

    final err = await c.submit('Etwas stimmt nicht');

    expect(err, isNotNull);
    expect(c.state, isA<AsyncError<void>>());
  });
}
