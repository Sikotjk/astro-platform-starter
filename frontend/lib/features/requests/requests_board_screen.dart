import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/customs.dart';
import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../models/package_request.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/user_avatar.dart';

/// IATA-Eingabe: nur Buchstaben, max. 3, großgeschrieben.
class _UpperCaseFormatter extends TextInputFormatter {
  const _UpperCaseFormatter();
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) =>
      n.copyWith(text: n.text.toUpperCase());
}

final _iataFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
  LengthLimitingTextInputFormatter(3),
  const _UpperCaseFormatter(),
];

class RequestsBoardScreen extends ConsumerStatefulWidget {
  const RequestsBoardScreen({super.key});

  @override
  ConsumerState<RequestsBoardScreen> createState() =>
      _RequestsBoardScreenState();
}

class _RequestsBoardScreenState extends ConsumerState<RequestsBoardScreen> {
  final _origin = TextEditingController();
  final _destination = TextEditingController();

  @override
  void dispose() {
    _origin.dispose();
    _destination.dispose();
    super.dispose();
  }

  void _search() {
    ref
        .read(requestsControllerProvider.notifier)
        .search(
          originAirport: _origin.text.trim(),
          destinationAirport: _destination.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(requestsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.requestsBoardTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('postRequestFab'),
        onPressed: () => context.push('/request/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.postRequestTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('reqOrigin'),
                    controller: _origin,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: _iataFormatters,
                    decoration: InputDecoration(
                      labelText: l10n.fieldFrom,
                      hintText: 'FRA',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    key: const Key('reqDestination'),
                    controller: _destination,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: _iataFormatters,
                    decoration: InputDecoration(
                      labelText: l10n.fieldTo,
                      hintText: 'DYU',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  key: const Key('reqSearch'),
                  onPressed: _search,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.when(
              data: (requests) => _RequestList(requests: requests),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  ErrorRetry(message: e.toString(), onRetry: _search),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({required this.requests});

  final List<PackageRequest> requests;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (requests.isEmpty) {
      return EmptyState(
        icon: Icons.inbox_rounded,
        message: l10n.noRequests,
        detail: l10n.noRequestsHint,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _RequestCard(request: requests[i]),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final PackageRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final r = request;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/request/${r.id}', extra: r),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      r.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Belohnung als prominentes Amber-Badge (der Anreiz).
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.amberGradient,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '+${r.rewardOffered.toStringAsFixed(0)} ${r.currency}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Pill(icon: Icons.flight_rounded, label: r.route),
                  _Pill(
                    icon: Icons.scale_rounded,
                    label: '${r.weightKg.toStringAsFixed(1)} kg',
                  ),
                  _Pill(
                    icon: Icons.category_rounded,
                    label: customsCategoryLabel(l10n, r.category),
                  ),
                ],
              ),
              if (r.sender != null) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    UserAvatar(name: r.sender!.firstName, radius: 14),
                    const SizedBox(width: 8),
                    Text(
                      r.sender!.firstName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (r.sender!.kycVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        size: 15,
                        color: AppColors.info,
                      ),
                    ],
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
