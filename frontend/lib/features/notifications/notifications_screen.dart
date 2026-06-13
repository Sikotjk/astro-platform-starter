import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/formatting.dart';
import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../widgets/animations.dart';
import '../../widgets/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _unreadOnly = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(notificationsControllerProvider.notifier).load(),
    );
  }

  Future<void> _refresh() => ref
      .read(notificationsControllerProvider.notifier)
      .load(unreadOnly: _unreadOnly);

  /// Markiert die Benachrichtigung als gelesen und springt bei einem
  /// Trip-Treffer direkt zur Buchungsansicht des passenden Trips.
  Future<void> _open(NotificationItem n) async {
    ref.read(notificationsControllerProvider.notifier).markRead(n.id);
    if (n.type == 'TRIP_MATCH' && n.tripId != null) {
      try {
        final trip = await ref.read(tripsRepositoryProvider).findOne(n.tripId!);
        if (mounted) context.push('/book', extra: trip);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);
    final hasUnread = state.maybeWhen(
      data: (items) => items.any((n) => !n.isRead),
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.notificationsTitle),
        actions: [
          TextButton(
            onPressed: hasUnread
                ? () => ref
                      .read(notificationsControllerProvider.notifier)
                      .markAllRead()
                : null,
            child: Text(context.l10n.markAllRead),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(context.l10n.filterAll),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(context.l10n.filterUnread),
                ),
              ],
              selected: {_unreadOnly},
              onSelectionChanged: (s) {
                setState(() => _unreadOnly = s.first);
                ref
                    .read(notificationsControllerProvider.notifier)
                    .load(unreadOnly: _unreadOnly);
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.when(
              data: (items) => RefreshIndicator(
                onRefresh: _refresh,
                child: _NotificationList(items: items, onTap: _open),
              ),
              loading: () => const ListSkeleton(),
              error: (e, _) => ErrorRetry(
                message: e.toString(),
                onRetry: () => ref
                    .read(notificationsControllerProvider.notifier)
                    .load(unreadOnly: _unreadOnly),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.items, required this.onTap});

  final List<NotificationItem> items;
  final void Function(NotificationItem) onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          EmptyState(
            icon: Icons.notifications_none_rounded,
            message: context.l10n.noNotifications,
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => FadeSlideIn(
        index: i,
        child: PressableScale(
          child: _NotificationCard(
            item: items[i],
            onTap: () => onTap(items[i]),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final n = item;
    final isTripMatch = n.type == 'TRIP_MATCH' && n.tripId != null;
    final (icon, color) = switch (n.type) {
      'TRIP_MATCH' => (Icons.flight_takeoff_rounded, AppColors.teal),
      'BOOKING_UPDATE' => (Icons.inventory_2_rounded, AppColors.info),
      _ => (Icons.notifications_rounded, AppColors.amberDeep),
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: n.isRead
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                ),
                          ),
                        ),
                        if (!n.isRead)
                          Container(
                            width: 9,
                            height: 9,
                            margin: const EdgeInsets.only(left: 8, top: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.teal,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      n.body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          context.timeAgo(n.createdAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.outline),
                        ),
                        const Spacer(),
                        if (isTripMatch)
                          Icon(
                            Icons.chevron_right,
                            color: scheme.onSurfaceVariant,
                            size: 20,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
