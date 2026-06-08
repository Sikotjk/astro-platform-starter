import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TJ-Shipping'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Abmelden',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Willkommen bei TJ-Shipping!'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.push('/trips'),
              icon: const Icon(Icons.search),
              label: const Text('Trips suchen'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => context.push('/bookings'),
              icon: const Icon(Icons.inventory_2),
              label: const Text('Meine Buchungen'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/notifications'),
              icon: const Icon(Icons.notifications),
              label: const Text('Benachrichtigungen'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/kyc'),
              icon: const Icon(Icons.verified_user),
              label: const Text('Identität verifizieren'),
            ),
          ],
        ),
      ),
    );
  }
}
