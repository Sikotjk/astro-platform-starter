import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../widgets/animations.dart';
import '../../widgets/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../models/package_request.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';

/// Liste der vom Sender selbst geposteten Wünsche.
class MyRequestsScreen extends ConsumerStatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  ConsumerState<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends ConsumerState<MyRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(myRequestsControllerProvider.notifier).load(),
    );
  }

  Future<void> _reload() =>
      ref.read(myRequestsControllerProvider.notifier).load();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(myRequestsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myRequestsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/request/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.postRequestTitle),
      ),
      body: state.when(
        loading: () => const ListSkeleton(),
        error: (e, _) => ErrorRetry(message: e.toString(), onRetry: _reload),
        data: (requests) => RefreshIndicator(
          onRefresh: _reload,
          child: requests.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 80),
                    EmptyState(
                      icon: Icons.outbox_rounded,
                      message: l10n.noMyRequests,
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: requests.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => FadeSlideIn(
                    index: i,
                    child: PressableScale(
                      child: _MyRequestCard(request: requests[i]),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _MyRequestCard extends StatelessWidget {
  const _MyRequestCard({required this.request});

  final PackageRequest request;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = request;
    final open = r.status == 'OPEN';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/request/${r.id}', extra: r),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.outbox_rounded, color: AppColors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${r.route} · ${r.weightKg.toStringAsFixed(1)} kg',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+${r.rewardOffered.toStringAsFixed(0)} ${r.currency}',
                    style: const TextStyle(
                      color: AppColors.amberDeep,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (open ? AppColors.success : scheme.outline)
                          .withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      r.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: open ? AppColors.success : scheme.outline,
                      ),
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
