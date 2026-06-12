import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n_ext.dart';
import 'core/providers.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/booking_create/create_booking_screen.dart';
import 'features/booking_detail/booking_detail_screen.dart';
import 'features/bookings/bookings_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/home/home_screen.dart';
import 'features/kyc/kyc_screen.dart';
import 'features/manifest/manifest_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/profile/profile_edit_screen.dart';
import 'features/requests/post_request_screen.dart';
import 'features/requests/request_detail_screen.dart';
import 'features/requests/requests_board_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/reviews/public_profile_screen.dart';
import 'models/booking_detail.dart';
import 'models/package_request.dart';
import 'features/saved_searches/saved_searches_screen.dart';
import 'features/trips/create_trip_screen.dart';
import 'features/trips/my_trips_screen.dart';
import 'features/trips/trips_search_screen.dart';
import 'models/auth.dart';
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
      // Haupt-Tabs mit Bottom-Navigation (Zustand pro Tab bleibt erhalten).
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _TabShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trips',
                builder: (_, _) => const TripsSearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (_, _) => const BookingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/trip/new', builder: (_, _) => const CreateTripScreen()),
      GoRoute(path: '/trips/mine', builder: (_, _) => const MyTripsScreen()),
      GoRoute(
        path: '/requests',
        builder: (_, _) => const RequestsBoardScreen(),
      ),
      GoRoute(
        path: '/request/new',
        builder: (_, _) => const PostRequestScreen(),
      ),
      GoRoute(
        path: '/request/:id',
        builder: (_, state) =>
            RequestDetailScreen(request: state.extra as PackageRequest),
      ),
      GoRoute(
        path: '/user',
        builder: (_, state) =>
            PublicProfileScreen(party: state.extra as BookingParty),
      ),
      GoRoute(
        path: '/saved-searches',
        builder: (_, _) => const SavedSearchesScreen(),
      ),
      GoRoute(
        path: '/book',
        builder: (_, state) => CreateBookingScreen(trip: state.extra as Trip),
      ),
      GoRoute(
        path: '/booking/:id',
        builder: (_, state) =>
            BookingDetailScreen(bookingId: state.pathParameters['id']!),
      ),
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
      GoRoute(
        path: '/profile/edit',
        builder: (_, state) =>
            ProfileEditScreen(profile: state.extra as UserProfile),
      ),
    ],
  );
});

/// Gerüst um die Haupt-Tabs: Inhalt + Bottom-Navigation.
class _TabShell extends StatelessWidget {
  const _TabShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.tabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search_rounded),
            label: l10n.tabSearch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2_rounded),
            label: l10n.tabBookings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}
