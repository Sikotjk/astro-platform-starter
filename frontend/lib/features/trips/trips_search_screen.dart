import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../models/trip.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Trips suchen')),
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
                        decoration: const InputDecoration(
                          labelText: 'Von (IATA)',
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
                        decoration: const InputDecoration(
                          labelText: 'Nach (IATA)',
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
                        decoration: const InputDecoration(
                          labelText: 'Min. freie kg',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _search,
                      icon: const Icon(Icons.search),
                      label: const Text('Suchen'),
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
              error: (e, _) => Center(child: Text(e.toString())),
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
    if (trips.isEmpty) {
      return const Center(child: Text('Keine Trips gefunden.'));
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
            'Abflug ${t.departureDate} · ${t.freeKg.toStringAsFixed(1)} kg frei · '
            '${t.pricePerKg.toStringAsFixed(2)} ${t.currency}/kg',
          ),
          trailing: t.traveler == null
              ? null
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t.traveler!.firstName),
                    Text('★ ${t.traveler!.ratingAvg.toStringAsFixed(1)}'),
                  ],
                ),
        );
      },
    );
  }
}
