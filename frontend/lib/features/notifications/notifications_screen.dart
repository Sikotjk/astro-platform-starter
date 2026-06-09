import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../models/notification.dart';

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
        data: (items) => _NotificationList(items: items),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.items});

  final List<NotificationItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text(context.l10n.noNotifications));
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final n = items[i];
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
          subtitle: Text(n.body),
        );
      },
    );
  }
}
