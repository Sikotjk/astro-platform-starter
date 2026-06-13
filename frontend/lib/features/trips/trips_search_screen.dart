import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatting.dart';
import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../widgets/animations.dart';
import '../../widgets/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../models/booking_detail.dart';
import '../../models/saved_search.dart';
import '../../models/trip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/traveler_reputation.dart';

/// Erzwingt Großbuchstaben (IATA-Codes sind immer großgeschrieben).
class _UpperCaseFormatter extends TextInputFormatter {
  const _UpperCaseFormatter();
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}

/// IATA-Eingabe: nur Buchstaben, max. 3, großgeschrieben.
final _iataFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
  LengthLimitingTextInputFormatter(3),
  const _UpperCaseFormatter(),
];

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

  Future<void> _saveSearch() async {
    final error = await ref
        .read(savedSearchesControllerProvider.notifier)
        .create(
          originAirport: _origin.text.trim(),
          destinationAirport: _destination.text.trim(),
          minFreeKg: double.tryParse(_minKg.text.trim()),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? context.l10n.searchSaved)));
  }

  Future<void> _openSaved() async {
    final picked = await context.push<SavedSearch>('/saved-searches');
    if (picked == null || !mounted) return;
    _origin.text = picked.originAirport ?? '';
    _destination.text = picked.destinationAirport ?? '';
    _minKg.text = picked.minFreeKg?.toStringAsFixed(0) ?? '';
    _search();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(tripsControllerProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tripsTitle),
        actions: [
          IconButton(
            key: const Key('saveSearch'),
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: l10n.saveSearch,
            onPressed: _saveSearch,
          ),
          IconButton(
            key: const Key('openSavedSearches'),
            icon: const Icon(Icons.bookmarks_outlined),
            tooltip: l10n.savedSearches,
            onPressed: _openSaved,
          ),
        ],
      ),
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
                        inputFormatters: _iataFormatters,
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
                        inputFormatters: _iataFormatters,
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
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
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
              loading: () => const ListSkeleton(),
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
      return EmptyState(
        icon: Icons.travel_explore_rounded,
        message: l10n.noTrips,
        detail: l10n.noTripsHint,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => FadeSlideIn(
        index: i,
        child: PressableScale(child: _TripCard(trip: trips[i])),
      ),
    );
  }
}

/// Karte für ein Trip-Angebot: Route, Eckdaten als Pills, Reisenden-Reputation.
class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/book', extra: trip),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.flight_takeoff_rounded,
                      color: AppColors.teal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      trip.route,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Pill(
                    icon: Icons.event_rounded,
                    label: context.formatDate(trip.departureAt),
                  ),
                  _Pill(
                    icon: Icons.scale_rounded,
                    label: '${trip.freeKg.toStringAsFixed(1)} kg',
                  ),
                  _Pill(
                    icon: Icons.sell_rounded,
                    label:
                        '${trip.pricePerKg.toStringAsFixed(2)} ${trip.currency}/kg',
                    highlight: true,
                  ),
                ],
              ),
              if (trip.traveler != null) ...[
                const Divider(height: 28),
                _TravelerBadge(traveler: trip.traveler!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Kleine Info-Pille (Icon + Text) für Trip-Eckdaten.
class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = highlight ? AppColors.amberDeep : scheme.onSurfaceVariant;
    final bg = highlight
        ? AppColors.amber.withValues(alpha: 0.14)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.6);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reputation des Reisenden; antippbar → öffentliches Profil mit Bewertungen.
class _TravelerBadge extends StatelessWidget {
  const _TravelerBadge({required this.traveler});

  final TripTraveler traveler;

  @override
  Widget build(BuildContext context) {
    final id = traveler.id;
    final badge = TravelerReputation(traveler: traveler);
    if (id == null) return badge; // ältere API-Antwort ohne id
    return InkWell(
      key: Key('travelerBadge_$id'),
      borderRadius: BorderRadius.circular(8),
      onTap: () => context.push(
        '/user',
        extra: BookingParty(
          id: id,
          firstName: traveler.firstName,
          ratingAvg: traveler.ratingAvg,
          ratingCount: traveler.ratingCount,
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(4), child: badge),
    );
  }
}
