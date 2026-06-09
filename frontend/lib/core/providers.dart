import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/auth_repository.dart';
import '../features/booking_create/create_booking_controller.dart';
import '../features/booking_create/packages_repository.dart';
import '../features/booking_detail/booking_detail_controller.dart';
import '../features/booking_detail/booking_detail_repository.dart';
import '../features/bookings/bookings_controller.dart';
import '../features/bookings/bookings_repository.dart';
import '../features/chat/chat_controller.dart';
import '../features/chat/chat_gateway.dart';
import '../features/chat/chat_repository.dart';
import '../features/chat/socket_chat_gateway.dart';
import '../features/kyc/kyc_controller.dart';
import '../features/kyc/kyc_repository.dart';
import '../features/manifest/manifest_controller.dart';
import '../features/manifest/manifest_repository.dart';
import '../features/manifest/manifest_viewer.dart';
import '../features/manifest/printing_manifest_viewer.dart';
import '../features/notifications/notifications_controller.dart';
import '../features/notifications/notifications_repository.dart';
import '../features/reviews/review_controller.dart';
import '../features/reviews/reviews_repository.dart';
import '../features/trips/trips_controller.dart';
import '../features/trips/trips_repository.dart';
import '../models/booking.dart';
import '../models/booking_detail.dart';
import '../models/message.dart';
import '../models/notification.dart';
import '../models/trip.dart';
import 'api_client.dart';
import 'config.dart';
import 'locale_controller.dart';
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

/// Einmaliger App-Start: versucht Auto-Login aus gespeichertem Token.
final appBootstrapProvider = FutureProvider<void>(
  (ref) => ref.read(authControllerProvider.notifier).restoreSession(),
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

// ── Buchungs-Detailsicht (Status-Verlauf + Aktionen) ─────────────────────────
final bookingDetailRepositoryProvider = Provider<BookingDetailRepository>(
  (ref) => DioBookingDetailRepository(ref.watch(apiClientProvider).dio),
);

final bookingDetailControllerProvider =
    StateNotifierProvider.family<
      BookingDetailController,
      AsyncValue<BookingDetail>,
      String
    >((ref, bookingId) {
      final controller = BookingDetailController(
        ref.watch(bookingDetailRepositoryProvider),
        bookingId,
      );
      controller.load();
      return controller;
    });

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

// ── Bewertungen (Reviews) ────────────────────────────────────────────────────
final reviewsRepositoryProvider = Provider<ReviewsRepository>(
  (ref) => DioReviewsRepository(ref.watch(apiClientProvider).dio),
);

final reviewControllerProvider =
    StateNotifierProvider.family<ReviewController, AsyncValue<void>, String>(
      (ref, bookingId) =>
          ReviewController(ref.watch(reviewsRepositoryProvider), bookingId),
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

// ── Zoll-Manifest (PDF) ──────────────────────────────────────────────────────
final manifestRepositoryProvider = Provider<ManifestRepository>(
  (ref) => DioManifestRepository(ref.watch(apiClientProvider).dio),
);

final manifestViewerProvider = Provider<ManifestViewer>(
  (ref) => const PrintingManifestViewer(),
);

final manifestControllerProvider =
    StateNotifierProvider.family<
      ManifestController,
      AsyncValue<ManifestPdf>,
      String
    >((ref, bookingId) {
      final locale = ref.watch(localeProvider).languageCode;
      final controller = ManifestController(
        ref.watch(manifestRepositoryProvider),
        bookingId,
        locale,
      );
      controller.load();
      return controller;
    });
