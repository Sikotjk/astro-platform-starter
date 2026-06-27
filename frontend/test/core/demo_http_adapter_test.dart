import 'package:flutter_test/flutter_test.dart';
import 'package:tj_shipping_app/core/api_client.dart';
import 'package:tj_shipping_app/core/demo/demo_http_adapter.dart';
import 'package:tj_shipping_app/core/token_store.dart';
import 'package:tj_shipping_app/features/auth/auth_repository.dart';
import 'package:tj_shipping_app/features/trips/trips_repository.dart';
import 'package:tj_shipping_app/models/trip.dart';

void main() {
  // Echter Dio-Stack (ApiClient + Repos) gegen den Demo-Adapter — beweist,
  // dass die Verdrahtung ohne Server funktioniert.
  late ApiClient client;

  setUp(() {
    client = ApiClient.create(
      InMemoryTokenStore()..write('demo'),
      baseUrl: 'http://demo.local',
      adapter: DemoHttpAdapter(),
    );
  });

  test('AuthRepository.me lädt das Demo-Profil über Dio', () async {
    final repo = DioAuthRepository(client.dio);
    final me = await repo.me();
    expect(me.firstName, 'Anvar');
    expect(me.isKycVerified, isTrue);
  });

  test('TripsRepository.search liefert gefilterte Trips über Dio', () async {
    final repo = DioTripsRepository(client.dio);
    final trips = await repo.search(
      const TripSearchQuery(originAirport: 'FRA', destinationAirport: 'DYU'),
    );
    expect(trips, hasLength(1));
    expect(trips.first.traveler?.firstName, 'Karim');
    expect(trips.first.traveler?.id, isNotNull);
  });

  test('Login über Dio liefert ein Token-Paar', () async {
    final repo = DioAuthRepository(client.dio);
    final session = await repo.login(email: 'a@b.de', password: 'x');
    expect(session.accessToken, isNotEmpty);
    expect(session.refreshToken, isNotEmpty);
  });
}
