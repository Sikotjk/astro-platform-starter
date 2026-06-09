import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking.dart';
import '../../models/booking_detail.dart';
import '../bookings/bookings_screen.dart';
import 'booking_actions.dart';

/// Lokalisierte Beschriftung je Aktion.
String bookingActionLabel(AppLocalizations l10n, BookingAction action) {
  return switch (action) {
    BookingAction.accept => l10n.actionAccept,
    BookingAction.reject => l10n.actionReject,
    BookingAction.pay => l10n.actionPay,
    BookingAction.acceptTerms => l10n.actionAcceptTerms,
    BookingAction.handover => l10n.actionHandover,
    BookingAction.transit => l10n.actionTransit,
    BookingAction.delivered => l10n.actionDelivered,
    BookingAction.confirm => l10n.actionConfirm,
    BookingAction.cancel => l10n.actionCancel,
  };
}

class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    BookingAction action,
  ) async {
    final error = await ref
        .read(bookingDetailControllerProvider(bookingId).notifier)
        .act(action);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(bookingDetailControllerProvider(bookingId));
    final myId = ref.watch(authControllerProvider).session?.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.detailTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: l10n.openChat,
            onPressed: () => context.push('/chat/$bookingId'),
          ),
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: l10n.manifestTitle,
            onPressed: () => context.push('/manifest/$bookingId'),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (booking) => _DetailBody(
          booking: booking,
          myId: myId,
          onAction: (a) => _run(context, ref, a),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.booking,
    required this.myId,
    required this.onAction,
  });

  final BookingDetail booking;
  final String? myId;
  final void Function(BookingAction) onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isSender = myId == booking.senderId;
    final isTraveler = myId == booking.travelerId;
    final actions = availableBookingActions(
      status: booking.status,
      isSender: isSender,
      isTraveler: isTraveler,
      termsAccepted: booking.termsAccepted,
    );
    final color = bookingStatusColor(booking.status);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                booking.packageTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Chip(
              label: Text(bookingStatusLabel(l10n, booking.status)),
              backgroundColor: color.withValues(alpha: 0.15),
              labelStyle: TextStyle(color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${l10n.amountLabel}: ${booking.totalAmount.toStringAsFixed(2)} ${booking.currency}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const Divider(height: 32),
        Text(l10n.actionsTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in actions)
              ElevatedButton(
                key: Key('action_${a.name}'),
                onPressed: () => onAction(a),
                child: Text(bookingActionLabel(l10n, a)),
              ),
          ],
        ),
        const Divider(height: 32),
        Text(
          l10n.timelineTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (booking.events.isEmpty)
          Text(l10n.noEvents)
        else
          for (final e in booking.events) _TimelineTile(event: e, l10n: l10n),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.event, required this.l10n});

  final BookingStatusEvent event;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = bookingStatusColor(event.toStatus);
    final d = event.createdAt.toLocal();
    final date =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return ListTile(
      dense: true,
      leading: Icon(Icons.circle, size: 14, color: color),
      title: Text(bookingStatusLabel(l10n, event.toStatus)),
      subtitle: Text(date),
    );
  }
}
