import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../models/trip.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/traveler_reputation.dart';

class TripsSearchScreen extends ConsumerStatefulWidget {
  const TripsSearchScreen({super.key});

  @override
  ConsumerState<TripsSearchScreen> createState() => _TripsSearchScreenState();
}

class _TripsSearchScreenState extends ConsumerState<TripsSearchScreen> {
  final _origin = TextEditingController();
  final _destination = TextEditingController();
  final _minKg = TextEditingController();

  @override
  void dispose() {
    _origin.dispose();
    _destination.dispose();
    _minKg.dispose();
    super.dispose();
  }

  void _search() {
    ref
        .read(tripsControllerProvider.notifier)
        .search(
          TripSearchQuery(
            originAirport: _origin.text.trim(),
            destinationAirport: _destination.text.trim(),
            minFreeKg: double.tryParse(_minKg.text.trim()),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(tripsControllerProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tripsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('origin'),
                        controller: _origin,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: l10n.fieldFrom,
                          hintText: 'FRA',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        key: const Key('destination'),
                        controller: _destination,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: l10n.fieldTo,
                          hintText: 'DYU',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('minKg'),
                        controller: _minKg,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.fieldMinKg),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _search,
                      icon: const Icon(Icons.search),
                      label: Text(l10n.searchButton),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: result.when(
              data: (trips) => _TripList(trips: trips),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  ErrorRetry(message: e.toString(), onRetry: _search),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripList extends StatelessWidget {
  const _TripList({required this.trips});

  final List<Trip> trips;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (trips.isEmpty) {
      return Center(child: Text(l10n.noTrips));
    }
    return ListView.separated(
      itemCount: trips.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final t = trips[i];
        return ListTile(
          title: Text(
            t.route,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            l10n.tripSubtitle(
              t.departureDate,
              t.freeKg.toStringAsFixed(1),
              t.pricePerKg.toStringAsFixed(2),
              t.currency,
            ),
          ),
          trailing: t.traveler == null
              ? null
              : TravelerReputation(traveler: t.traveler!),
          onTap: () => context.push('/book', extra: t),
        );
      },
    );
  }
}
