import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../widgets/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking.dart';
import '../../widgets/empty_state.dart';
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
              loading: () => const ListSkeleton(),
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
          const SizedBox(height: 80),
          EmptyState(
            icon: Icons.inventory_2_outlined,
            message: l10n.noBookings,
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _BookingCard(booking: bookings[i]),
    );
  }
}

/// Karte für eine Buchung in der Übersicht.
class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final BookingSummary booking;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final b = booking;
    final color = bookingStatusColor(b.status);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/booking/${b.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      b.route,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      bookingStatusLabel(l10n, b.status),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                b.packageTitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    paymentStatusIcon(b.paymentStatus),
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    paymentStatusLabel(l10n, b.paymentStatus),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '${b.totalAmount.toStringAsFixed(2)} ${b.currency}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
