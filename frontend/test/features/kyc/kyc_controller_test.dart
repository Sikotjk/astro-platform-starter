import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/features/kyc/kyc_controller.dart';
import 'package:tj_shipping_app/features/kyc/kyc_repository.dart';
import 'package:tj_shipping_app/models/kyc.dart';

class _FakeKycRepo implements KycRepository {
  _FakeKycRepo({this.currentStatus = 'NOT_STARTED', this.fail = false});
  String currentStatus;
  bool fail;
  int sessionCalls = 0;

  @override
  Future<String> status() async {
    if (fail) throw Exception('boom');
    return currentStatus;
  }

  @override
  Future<KycSession> startSession() async {
    sessionCalls++;
    return const KycSession(clientSecret: 'vs_secret', sessionId: 'vs_1');
  }
}

void main() {
  test('KycSession.fromJson', () {
    final s = KycSession.fromJson({'clientSecret': 'cs', 'sessionId': 'sid'});
    expect(s.clientSecret, 'cs');
    expect(s.sessionId, 'sid');
  });

  test('refresh übernimmt den Status', () async {
    final c = KycController(_FakeKycRepo(currentStatus: 'VERIFIED'));
    await c.refresh();
    expect(c.state.status, 'VERIFIED');
    expect(c.state.isVerified, isTrue);
  });

  test('startVerification -> PENDING + clientSecret', () async {
    final repo = _FakeKycRepo();
    final c = KycController(repo);
    await c.startVerification();
    expect(c.state.status, 'PENDING');
    expect(c.state.clientSecret, 'vs_secret');
    expect(repo.sessionCalls, 1);
  });

  test('Fehler bei refresh -> error-Feld gesetzt', () async {
    final c = KycController(_FakeKycRepo(fail: true));
    await c.refresh();
    expect(c.state.error, isNotNull);
    expect(c.state.loading, isFalse);
  });
}
