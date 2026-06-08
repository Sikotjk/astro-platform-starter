import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../widgets/language_menu.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          const LanguageMenu(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.homeWelcome),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.push('/trips'),
              icon: const Icon(Icons.search),
              label: Text(l10n.homeSearchTrips),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => context.push('/bookings'),
              icon: const Icon(Icons.inventory_2),
              label: Text(l10n.homeMyBookings),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/notifications'),
              icon: const Icon(Icons.notifications),
              label: Text(l10n.homeNotifications),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/kyc'),
              icon: const Icon(Icons.verified_user),
              label: Text(l10n.homeVerify),
            ),
          ],
        ),
      ),
    );
  }
}
