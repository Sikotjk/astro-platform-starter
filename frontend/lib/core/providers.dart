import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/auth_repository.dart';
import '../features/trips/trips_controller.dart';
import '../features/trips/trips_repository.dart';
import '../models/trip.dart';
import 'api_client.dart';
import 'token_store.dart';

/// Zentrale Provider-Definitionen (Dependency Injection der App).
final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient.create(ref.watch(tokenStoreProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => DioAuthRepository(ref.watch(apiClientProvider).dio),
);

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(
    ref.watch(authRepositoryProvider),
    ref.watch(tokenStoreProvider),
  ),
);

final tripsRepositoryProvider = Provider<TripsRepository>(
  (ref) => DioTripsRepository(ref.watch(apiClientProvider).dio),
);

final tripsControllerProvider =
    StateNotifierProvider<TripsController, AsyncValue<List<Trip>>>(
      (ref) => TripsController(ref.watch(tripsRepositoryProvider)),
    );
