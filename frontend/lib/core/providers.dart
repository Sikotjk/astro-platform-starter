import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/auth_repository.dart';
import '../features/booking_create/create_booking_controller.dart';
import '../features/booking_create/packages_repository.dart';
import '../features/bookings/bookings_controller.dart';
import '../features/bookings/bookings_repository.dart';
import '../features/chat/chat_controller.dart';
import '../features/chat/chat_gateway.dart';
import '../features/chat/chat_repository.dart';
import '../features/chat/socket_chat_gateway.dart';
import '../features/kyc/kyc_controller.dart';
import '../features/kyc/kyc_repository.dart';
import '../features/notifications/notifications_controller.dart';
import '../features/notifications/notifications_repository.dart';
import '../features/trips/trips_controller.dart';
import '../features/trips/trips_repository.dart';
import '../models/booking.dart';
import '../models/message.dart';
import '../models/notification.dart';
import '../models/trip.dart';
import 'api_client.dart';
import 'config.dart';
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

final kycRepositoryProvider = Provider<KycRepository>(
  (ref) => DioKycRepository(ref.watch(apiClientProvider).dio),
);

final kycControllerProvider = StateNotifierProvider<KycController, KycState>(
  (ref) => KycController(ref.watch(kycRepositoryProvider)),
);

final bookingsRepositoryProvider = Provider<BookingsRepository>(
  (ref) => DioBookingsRepository(ref.watch(apiClientProvider).dio),
);

final bookingsControllerProvider =
    StateNotifierProvider<BookingsController, AsyncValue<List<BookingSummary>>>(
      (ref) => BookingsController(ref.watch(bookingsRepositoryProvider)),
    );

// ── Buchung anlegen (Paket + Booking) ────────────────────────────────────────
final packagesRepositoryProvider = Provider<PackagesRepository>(
  (ref) => DioPackagesRepository(ref.watch(apiClientProvider).dio),
);

final createBookingControllerProvider =
    StateNotifierProvider<CreateBookingController, CreateBookingState>(
      (ref) => CreateBookingController(
        ref.watch(packagesRepositoryProvider),
        ref.watch(bookingsRepositoryProvider),
      ),
    );

// ── Benachrichtigungen ───────────────────────────────────────────────────────
final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => DioNotificationsRepository(ref.watch(apiClientProvider).dio),
);

final notificationsControllerProvider =
    StateNotifierProvider<
      NotificationsController,
      AsyncValue<List<NotificationItem>>
    >(
      (ref) =>
          NotificationsController(ref.watch(notificationsRepositoryProvider)),
    );

// ── Chat (REST-Verlauf + Echtzeit-WebSocket) ─────────────────────────────────
final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => DioChatRepository(ref.watch(apiClientProvider).dio),
);

final chatGatewayProvider = Provider<ChatGateway>((ref) {
  final token = ref.watch(authControllerProvider).session?.accessToken ?? '';
  final gateway = SocketChatGateway(
    baseUrl: AppConfig.apiBaseUrl,
    token: token,
  );
  ref.onDispose(gateway.dispose);
  return gateway;
});

final chatControllerProvider =
    StateNotifierProvider.family<
      ChatController,
      AsyncValue<List<Message>>,
      String
    >((ref, bookingId) {
      final controller = ChatController(
        ref.watch(chatRepositoryProvider),
        ref.watch(chatGatewayProvider),
        bookingId,
      );
      controller.init();
      return controller;
    });
