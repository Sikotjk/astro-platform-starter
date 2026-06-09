import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/formatting.dart';
import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../models/notification.dart';
import '../../widgets/error_retry.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(notificationsControllerProvider.notifier).load(),
    );
  }

  Future<void> _refresh() =>
      ref.read(notificationsControllerProvider.notifier).load();

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

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.notificationsTitle),
        actions: [
          TextButton(
            onPressed: () => ref
                .read(notificationsControllerProvider.notifier)
                .markAllRead(),
            child: Text(context.l10n.markAllRead),
          ),
        ],
      ),
      body: state.when(
        data: (items) => RefreshIndicator(
          onRefresh: _refresh,
          child: _NotificationList(items: items, onTap: _open),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetry(
          message: e.toString(),
          onRetry: () =>
              ref.read(notificationsControllerProvider.notifier).load(),
        ),
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
          const SizedBox(height: 120),
          Center(child: Text(context.l10n.noNotifications)),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final n = items[i];
        final isTripMatch = n.type == 'TRIP_MATCH' && n.tripId != null;
        return ListTile(
          leading: Icon(
            n.isRead ? Icons.notifications_none : Icons.notifications_active,
            color: n.isRead
                ? Theme.of(context).colorScheme.outline
                : Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            n.title,
            style: TextStyle(
              fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(n.body),
              const SizedBox(height: 2),
              Text(
                context.timeAgo(n.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          isThreeLine: true,
          trailing: isTripMatch ? const Icon(Icons.chevron_right) : null,
          onTap: () => onTap(n),
        );
      },
    );
  }
}
