import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking.dart';
import '../../widgets/error_retry.dart';

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

/// Lokalisierte Beschriftung je Zahlungsstatus.
String paymentStatusLabel(AppLocalizations l10n, String paymentStatus) {
  return switch (paymentStatus) {
    'ESCROW_HELD' => l10n.payStatusEscrowHeld,
    'RELEASED' => l10n.payStatusReleased,
    'REFUNDED' => l10n.payStatusRefunded,
    'FAILED' => l10n.payStatusFailed,
    _ => l10n.payStatusPending,
  };
}

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

/// Statusgruppen für den Grobfilter (kommagetrennt, wie vom Backend erwartet).
const _activeStatuses =
    'REQUESTED,ACCEPTED,PAID,HANDED_OVER,IN_TRANSIT,DELIVERED,DISPUTED';
const _doneStatuses = 'CONFIRMED,CANCELLED,REJECTED,REFUNDED';

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  String? _role; // null = alle, 'SENDER', 'TRAVELER'
  String? _statusGroup; // null = alle, 'active', 'done'

  @override
  void initState() {
    super.initState();
    Future.microtask(_reload);
  }

  String? get _statusFilter => switch (_statusGroup) {
    'active' => _activeStatuses,
    'done' => _doneStatuses,
    _ => null,
  };

  void _reload() {
    ref
        .read(bookingsControllerProvider.notifier)
        .load(role: _role, status: _statusFilter);
  }

  Future<void> _refresh() => ref
      .read(bookingsControllerProvider.notifier)
      .load(role: _role, status: _statusFilter);

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String?>(
              segments: [
                ButtonSegment(value: null, label: Text(l10n.filterAll)),
                ButtonSegment(value: 'active', label: Text(l10n.filterActive)),
                ButtonSegment(value: 'done', label: Text(l10n.filterDone)),
              ],
              selected: {_statusGroup},
              onSelectionChanged: (s) {
                setState(() => _statusGroup = s.first);
                _reload();
              },
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Expanded(
            child: state.when(
              data: (bookings) => RefreshIndicator(
                onRefresh: _refresh,
                child: _BookingList(bookings: bookings),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  ErrorRetry(message: e.toString(), onRetry: _reload),
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
      // Scrollbar halten, damit Pull-to-Refresh auch im Leerzustand greift.
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(child: Text(l10n.noBookings)),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${b.packageTitle} · ${b.totalAmount.toStringAsFixed(2)} ${b.currency}',
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    paymentStatusIcon(b.paymentStatus),
                    size: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    paymentStatusLabel(l10n, b.paymentStatus),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          isThreeLine: true,
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
