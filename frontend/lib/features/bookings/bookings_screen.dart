import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking.dart';

/// Lokalisierte Beschriftung je Buchungsstatus.
String bookingStatusLabel(AppLocalizations l10n, String status) {
  return switch (status) {
    'REQUESTED' => l10n.statusRequested,
    'ACCEPTED' => l10n.statusAccepted,
    'PAID' => l10n.statusPaid,
    'HANDED_OVER' => l10n.statusHandedOver,
    'IN_TRANSIT' => l10n.statusInTransit,
    'DELIVERED' => l10n.statusDelivered,
    'CONFIRMED' => l10n.statusConfirmed,
    'DISPUTED' => l10n.statusDisputed,
    'REFUNDED' => l10n.statusRefunded,
    'CANCELLED' => l10n.statusCancelled,
    'REJECTED' => l10n.statusRejected,
    _ => status,
  };
}

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  String? _role; // null = alle, 'SENDER', 'TRAVELER'

  @override
  void initState() {
    super.initState();
    Future.microtask(_reload);
  }

  void _reload() {
    ref.read(bookingsControllerProvider.notifier).load(role: _role);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingsControllerProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookingsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: _reload,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String?>(
              segments: [
                ButtonSegment(value: null, label: Text(l10n.filterAll)),
                ButtonSegment(
                  value: 'SENDER',
                  label: Text(l10n.filterAsSender),
                ),
                ButtonSegment(
                  value: 'TRAVELER',
                  label: Text(l10n.filterAsTraveler),
                ),
              ],
              selected: {_role},
              onSelectionChanged: (s) {
                setState(() => _role = s.first);
                _reload();
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.when(
              data: (bookings) => _BookingList(bookings: bookings),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({required this.bookings});

  final List<BookingSummary> bookings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (bookings.isEmpty) {
      return Center(child: Text(l10n.noBookings));
    }
    return ListView.separated(
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final b = bookings[i];
        final color = bookingStatusColor(b.status);
        return ListTile(
          title: Text(
            b.route,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${b.packageTitle} · ${b.totalAmount.toStringAsFixed(2)} ${b.currency}',
          ),
          trailing: Chip(
            label: Text(bookingStatusLabel(l10n, b.status)),
            backgroundColor: color.withValues(alpha: 0.15),
            labelStyle: TextStyle(color: color),
          ),
          onTap: () => context.push('/booking/${b.id}'),
        );
      },
    );
  }
}
