import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/providers.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/booking_create/create_booking_screen.dart';
import 'features/bookings/bookings_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/home/home_screen.dart';
import 'features/kyc/kyc_screen.dart';
import 'features/manifest/manifest_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/trips/trips_search_screen.dart';
import 'models/trip.dart';

/// Router mit Auth-Redirect: nicht angemeldet -> /login, angemeldet -> /home.
final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<bool>(
    ref.read(authControllerProvider).isAuthenticated,
  );
  ref.listen(
    authControllerProvider,
    (_, next) => refresh.value = next.isAuthenticated,
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final isAuth = ref.read(authControllerProvider).isAuthenticated;
      final loc = state.matchedLocation;
      final isPublic = loc == '/login' || loc == '/register';
      if (!isAuth) return isPublic ? null : '/login';
      if (isPublic) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/trips', builder: (_, _) => const TripsSearchScreen()),
      GoRoute(
        path: '/book',
        builder: (_, state) => CreateBookingScreen(trip: state.extra as Trip),
      ),
      GoRoute(path: '/bookings', builder: (_, _) => const BookingsScreen()),
      GoRoute(
        path: '/chat/:id',
        builder: (_, state) =>
            ChatScreen(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/manifest/:id',
        builder: (_, state) =>
            ManifestScreen(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(path: '/kyc', builder: (_, _) => const KycScreen()),
    ],
  );
});
