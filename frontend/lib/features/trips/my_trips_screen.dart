import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../models/trip.dart';
import '../../widgets/error_retry.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(myTripsControllerProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(myTripsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myTripsTitle)),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetry(
          message: e.toString(),
          onRetry: () => ref.read(myTripsControllerProvider.notifier).load(),
        ),
        data: (trips) {
          if (trips.isEmpty) {
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(myTripsControllerProvider.notifier).load(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text(l10n.noMyTrips)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(myTripsControllerProvider.notifier).load(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: trips.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) => _MyTripTile(trip: trips[i]),
            ),
          );
        },
      ),
    );
  }
}

class _MyTripTile extends StatelessWidget {
  const _MyTripTile({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        trip.route,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${context.formatDate(trip.departureAt)} · '
        '${trip.freeKg.toStringAsFixed(1)} kg · '
        '${trip.pricePerKg.toStringAsFixed(2)} ${trip.currency}/kg',
      ),
      // Trip-Status (ACTIVE/FULL/…) ist aktuell nicht eigens lokalisiert.
      trailing: trip.status == null
          ? null
          : Chip(
              label: Text(trip.status!),
              visualDensity: VisualDensity.compact,
            ),
    );
  }
}
