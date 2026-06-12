import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/auth_repository.dart';
import '../features/booking_create/create_booking_controller.dart';
import '../features/booking_create/packages_repository.dart';
import '../features/booking_detail/booking_detail_controller.dart';
import '../features/booking_detail/booking_detail_repository.dart';
import '../features/disputes/dispute_controller.dart';
import '../features/disputes/disputes_repository.dart';
import '../features/payments/payment_gateway.dart';
import '../features/payments/stripe_payment_gateway.dart';
import '../features/bookings/bookings_controller.dart';
import '../features/bookings/bookings_repository.dart';
import '../features/chat/chat_controller.dart';
import '../features/chat/chat_gateway.dart';
import '../features/chat/chat_repository.dart';
import '../features/chat/socket_chat_gateway.dart';
import '../features/kyc/kyc_controller.dart';
import '../features/kyc/kyc_repository.dart';
import '../features/manifest/manifest_cache.dart';
import '../features/manifest/manifest_controller.dart';
import '../features/manifest/manifest_repository.dart';
import '../features/manifest/manifest_viewer.dart';
import '../features/manifest/printing_manifest_viewer.dart';
import '../features/notifications/notifications_controller.dart';
import '../features/notifications/notifications_repository.dart';
import '../features/profile/profile_controller.dart';
import '../features/requests/requests_controller.dart';
import '../features/requests/requests_repository.dart';
import '../features/reviews/review_controller.dart';
import '../features/reviews/reviews_repository.dart';
import '../features/reviews/user_reviews_controller.dart';
import '../features/saved_searches/saved_searches_controller.dart';
import '../features/saved_searches/saved_searches_repository.dart';
import '../features/trips/create_trip_controller.dart';
import '../features/trips/my_trips_controller.dart';
import '../features/trips/trips_controller.dart';
import '../features/trips/trips_repository.dart';
import '../models/booking.dart';
import '../models/booking_detail.dart';
import '../models/message.dart';
import '../models/notification.dart';
import '../models/package_request.dart';
import '../models/review.dart';
import '../models/saved_search.dart';
import '../models/trip.dart';
import 'api_client.dart';
import 'config.dart';
import 'demo/demo_http_adapter.dart';
import 'locale_controller.dart';
import 'token_store.dart';

/// Zentrale Provider-Definitionen (Dependency Injection der App).
///
/// Im Demo-Modus (`--dart-define=DEMO_MODE=true`) wird ein vorbefüllter
/// In-Memory-Token-Store genutzt, sodass die App direkt angemeldet startet.
final tokenStoreProvider = Provider<TokenStore>((ref) {
  if (AppConfig.isDemoMode) {
    final store = InMemoryTokenStore();
    store.write('demo-access-token');
    store.writeRefresh('demo-refresh-token');
    return store;
  }
  return SecureTokenStore();
});

/// Zählt 401-Antworten. Entkoppelt den ApiClient vom AuthController (sonst
/// entstünde ein Provider-Zyklus apiClient→authController→authRepository).
/// Die App lauscht darauf und meldet die Session ab.
final sessionExpiredProvider = StateProvider<int>((ref) => 0);

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient.create(
    ref.watch(tokenStoreProvider),
    onUnauthorized: () => ref.read(sessionExpiredProvider.notifier).state++,
    adapter: AppConfig.isDemoMode ? DemoHttpAdapter() : null,
  ),
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

final createTripControllerProvider =
    StateNotifierProvider<CreateTripController, AsyncValue<void>>(
      (ref) => CreateTripController(ref.watch(tripsRepositoryProvider)),
    );

final myTripsControllerProvider =
    StateNotifierProvider<MyTripsController, AsyncValue<List<Trip>>>(
      (ref) => MyTripsController(ref.watch(tripsRepositoryProvider)),
    );

// ── Wunsch-Board (umgekehrter Marktplatz) ────────────────────────────────────
final requestsRepositoryProvider = Provider<RequestsRepository>(
  (ref) => DioRequestsRepository(ref.watch(apiClientProvider).dio),
);

final requestsControllerProvider =
    StateNotifierProvider<RequestsController, AsyncValue<List<PackageRequest>>>(
      (ref) => RequestsController(ref.watch(requestsRepositoryProvider)),
    );

final createRequestControllerProvider =
    StateNotifierProvider<CreateRequestController, AsyncValue<void>>(
      (ref) => CreateRequestController(ref.watch(requestsRepositoryProvider)),
    );

final myRequestsControllerProvider =
    StateNotifierProvider<
      MyRequestsController,
      AsyncValue<List<PackageRequest>>
    >((ref) => MyRequestsController(ref.watch(requestsRepositoryProvider)));

// Angebote eines Wunsches (Eigentümer-Sicht), je requestId.
final requestOffersControllerProvider =
    StateNotifierProvider.family<
      RequestOffersController,
      AsyncValue<List<RequestOffer>>,
      String
    >(
      (ref, requestId) => RequestOffersController(
        ref.watch(requestsRepositoryProvider),
        requestId,
      ),
    );

// Angebot abgeben (Reisenden-Sicht), je requestId.
final makeOfferControllerProvider =
    StateNotifierProvider.family<MakeOfferController, AsyncValue<void>, String>(
      (ref, requestId) =>
          MakeOfferController(ref.watch(requestsRepositoryProvider), requestId),
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

// ── Zahlungen (Stripe) ───────────────────────────────────────────────────────
final paymentGatewayProvider = Provider<PaymentGateway>(
  (ref) => const StripePaymentGateway(),
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

// ── Streitfälle (Disputes) ───────────────────────────────────────────────────
final disputesRepositoryProvider = Provider<DisputesRepository>(
  (ref) => DioDisputesRepository(ref.watch(apiClientProvider).dio),
);

final disputeControllerProvider =
    StateNotifierProvider.family<DisputeController, AsyncValue<void>, String>(
      (ref, bookingId) =>
          DisputeController(ref.watch(disputesRepositoryProvider), bookingId),
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

// ── Bewertungen (Reviews) ────────────────────────────────────────────────────
final reviewsRepositoryProvider = Provider<ReviewsRepository>(
  (ref) => DioReviewsRepository(ref.watch(apiClientProvider).dio),
);

final reviewControllerProvider =
    StateNotifierProvider.family<ReviewController, AsyncValue<void>, String>(
      (ref, bookingId) =>
          ReviewController(ref.watch(reviewsRepositoryProvider), bookingId),
    );

final userReviewsControllerProvider =
    StateNotifierProvider.family<
      UserReviewsController,
      AsyncValue<List<Review>>,
      String
    >(
      (ref, userId) =>
          UserReviewsController(ref.watch(reviewsRepositoryProvider), userId),
    );

// ── Profil (eigenes Profil + erhaltene Bewertungen) ──────────────────────────
final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<ProfileData>>(
      (ref) => ProfileController(
        ref.watch(authRepositoryProvider),
        ref.watch(reviewsRepositoryProvider),
      ),
    );

// ── Gespeicherte Suchen ──────────────────────────────────────────────────────
final savedSearchesRepositoryProvider = Provider<SavedSearchesRepository>(
  (ref) => DioSavedSearchesRepository(ref.watch(apiClientProvider).dio),
);

final savedSearchesControllerProvider =
    StateNotifierProvider<
      SavedSearchesController,
      AsyncValue<List<SavedSearch>>
    >(
      (ref) =>
          SavedSearchesController(ref.watch(savedSearchesRepositoryProvider)),
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
  // Demo-Modus: kein echter Socket — der Verlauf kommt aus dem Demo-Backend.
  if (AppConfig.isDemoMode) {
    final gateway = FakeChatGateway();
    ref.onDispose(gateway.dispose);
    return gateway;
  }
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

final manifestCacheProvider = Provider<ManifestCache>(
  (ref) => FileManifestCache(),
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
        ref.watch(manifestCacheProvider),
        bookingId,
        locale,
      );
      controller.load();
      return controller;
    });
