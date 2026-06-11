import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../core/customs.dart';
import '../../core/formatting.dart';
import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking.dart';
import '../../models/booking_detail.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/user_avatar.dart';
import '../bookings/bookings_screen.dart';
import '../disputes/dispute_dialog.dart';
import '../disputes/dispute_rules.dart';
import '../reviews/review_dialog.dart';
import 'booking_actions.dart';
import 'booking_detail_controller.dart';

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
    if (action == BookingAction.pay) {
      await _pay(context, ref);
      return;
    }
    final error = await ref
        .read(bookingDetailControllerProvider(bookingId).notifier)
        .act(action);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _pay(BuildContext context, WidgetRef ref) async {
    if (!AppConfig.isStripeConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.paymentNotConfigured)),
      );
      return;
    }
    final gateway = ref.read(paymentGatewayProvider);
    final outcome = await ref
        .read(bookingDetailControllerProvider(bookingId).notifier)
        .pay(gateway);
    if (!context.mounted) return;
    final message = switch (outcome.status) {
      PaymentStatus.success => context.l10n.paymentSuccess,
      PaymentStatus.failed => outcome.error ?? context.l10n.paymentSuccess,
      PaymentStatus.cancelled => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _review(BuildContext context) async {
    final ok = await showReviewDialog(context, bookingId);
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.reviewSuccess)));
    }
  }

  Future<void> _dispute(BuildContext context, WidgetRef ref) async {
    final ok = await showDisputeDialog(context, bookingId);
    if (ok == true) {
      await ref
          .read(bookingDetailControllerProvider(bookingId).notifier)
          .load();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.disputeSuccess)));
      }
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
        error: (e, _) => ErrorRetry(
          message: e.toString(),
          onRetry: () => ref
              .read(bookingDetailControllerProvider(bookingId).notifier)
              .load(),
        ),
        data: (booking) => _DetailBody(
          booking: booking,
          myId: myId,
          onAction: (a) => _run(context, ref, a),
          onReview: () => _review(context),
          onDispute: () => _dispute(context, ref),
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
    required this.onReview,
    required this.onDispute,
  });

  final BookingDetail booking;
  final String? myId;
  final void Function(BookingAction) onAction;
  final VoidCallback onReview;
  final VoidCallback onDispute;

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
    final canReview = booking.status == 'CONFIRMED' && (isSender || isTraveler);
    final canDispute = canOpenDispute(
      status: booking.status,
      isSender: isSender,
      isTraveler: isTraveler,
    );
    final partner = booking.counterparty(myId);

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
        if (booking.route != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.flight, size: 16),
              const SizedBox(width: 6),
              Text(
                booking.departureAt != null
                    ? '${booking.route} · ${context.formatDate(booking.departureAt!)}'
                    : booking.route!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Text(
          '${l10n.amountLabel}: ${booking.totalAmount.toStringAsFixed(2)} ${booking.currency}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              paymentStatusIcon(booking.paymentStatus),
              size: 18,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 6),
            Text(
              paymentStatusLabel(l10n, booking.paymentStatus),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        if (partner != null) ...[
          const SizedBox(height: 12),
          _PartnerCard(party: partner),
        ],
        if (booking.items.isNotEmpty) ...[
          const Divider(height: 32),
          Text(
            l10n.contentSection,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          for (final item in booking.items) _ContentTile(item: item),
        ],
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
            if (canReview)
              FilledButton.icon(
                key: const Key('action_review'),
                onPressed: onReview,
                icon: const Icon(Icons.star_outline, size: 18),
                label: Text(l10n.reviewAction),
              ),
            if (canDispute)
              OutlinedButton.icon(
                key: const Key('action_dispute'),
                onPressed: onDispute,
                icon: const Icon(Icons.gavel, size: 18),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                label: Text(l10n.disputeAction),
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

/// Ein Posten der Zoll-Deklaration in der Detailansicht.
class _ContentTile extends StatelessWidget {
  const _ContentTile({required this.item});

  final BookingPackageItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final category = customsCategoryLabel(l10n, item.category);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        item.isSealed ? Icons.lock_outline : Icons.inventory_2_outlined,
        size: 20,
      ),
      title: Text(item.description.isEmpty ? category : item.description),
      subtitle: Text(
        '$category · ${item.quantity}× · '
        '${item.unitValueEur.toStringAsFixed(2)} €',
      ),
    );
  }
}

/// Karte mit der Reputation der Gegenpartei (Name, Sterne, Anzahl/„Neu").
class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.party});

  final BookingParty party;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasReviews = party.ratingCount > 0;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        key: const Key('partnerCard'),
        leading: UserAvatar(name: party.firstName, url: party.avatarUrl),
        title: Text(
          party.firstName.isEmpty ? l10n.bookingPartner : party.firstName,
        ),
        subtitle: Row(
          children: [
            if (hasReviews) ...[
              StarRating(value: party.ratingAvg.round(), size: 16),
              const SizedBox(width: 6),
              Text(
                '${party.ratingAvg.toStringAsFixed(1)} '
                '(${l10n.reviewsCount(party.ratingCount)})',
              ),
            ] else
              Text(l10n.newTraveler),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/user', extra: party),
      ),
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
    return ListTile(
      dense: true,
      leading: Icon(Icons.circle, size: 14, color: color),
      title: Text(bookingStatusLabel(l10n, event.toStatus)),
      subtitle: Text(context.formatDateTime(event.createdAt)),
    );
  }
}
