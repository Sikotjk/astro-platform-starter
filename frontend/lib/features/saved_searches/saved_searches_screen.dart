import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../widgets/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../models/saved_search.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';

/// Liste der gespeicherten Suchen. Tippen wählt eine Suche aus (pop mit
/// Ergebnis), das Lösch-Icon entfernt sie.
class SavedSearchesScreen extends ConsumerStatefulWidget {
  const SavedSearchesScreen({super.key});

  @override
  ConsumerState<SavedSearchesScreen> createState() =>
      _SavedSearchesScreenState();
}

class _SavedSearchesScreenState extends ConsumerState<SavedSearchesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(savedSearchesControllerProvider.notifier).load(),
    );
  }

  Future<void> _delete(SavedSearch s) async {
    final error = await ref
        .read(savedSearchesControllerProvider.notifier)
        .remove(s.id);
    if (error != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(savedSearchesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.savedSearches)),
      body: state.when(
        loading: () => const ListSkeleton(),
        error: (e, _) => ErrorRetry(
          message: e.toString(),
          onRetry: () =>
              ref.read(savedSearchesControllerProvider.notifier).load(),
        ),
        data: (searches) {
          if (searches.isEmpty) {
            return EmptyState(
              icon: Icons.bookmark_border_rounded,
              message: l10n.noSavedSearches,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: searches.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final s = searches[i];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.bookmark_rounded,
                      color: AppColors.teal,
                    ),
                  ),
                  title: Text(
                    s.route,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  subtitle: s.minFreeKg != null
                      ? Text(
                          '${l10n.fieldMinKg}: ${s.minFreeKg!.toStringAsFixed(0)}',
                        )
                      : null,
                  trailing: IconButton(
                    key: Key('delete_${s.id}'),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.deleteSearch,
                    onPressed: () => _delete(s),
                  ),
                  onTap: () => context.pop(s),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
