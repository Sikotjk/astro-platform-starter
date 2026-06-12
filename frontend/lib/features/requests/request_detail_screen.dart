import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/customs.dart';
import '../../core/formatting.dart';
import '../../core/l10n_ext.dart';
import '../../core/theme/app_theme.dart';
import '../../models/booking_detail.dart';
import '../../models/package_request.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/user_avatar.dart';

/// Detailansicht eines Liefer-Wunsches vom Board.
class RequestDetailScreen extends ConsumerWidget {
  const RequestDetailScreen({super.key, required this.request});

  final PackageRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final r = request;
    final s = r.sender;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.requestDetailTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kopfkarte mit Verlauf: Titel + Belohnung.
          Card(
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.flight_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        r.route,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.rewardLabel,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '+${r.rewardOffered.toStringAsFixed(2)} ${r.currency}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.scale_rounded,
                    label: l10n.fieldWeightKg,
                    value: '${r.weightKg.toStringAsFixed(1)} kg',
                  ),
                  const Divider(height: 20),
                  _DetailRow(
                    icon: Icons.category_rounded,
                    label: l10n.fieldCategory,
                    value: customsCategoryLabel(l10n, r.category),
                  ),
                  if (r.desiredByDate != null) ...[
                    const Divider(height: 20),
                    _DetailRow(
                      icon: Icons.event_rounded,
                      label: l10n.desiredBy,
                      value: context.formatDate(r.desiredByDate!),
                    ),
                  ],
                  if (r.notes != null && r.notes!.isNotEmpty) ...[
                    const Divider(height: 20),
                    _DetailRow(
                      icon: Icons.notes_rounded,
                      label: l10n.fieldNotesOptional,
                      value: r.notes!,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (s != null) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: UserAvatar(name: s.firstName, radius: 22),
                title: Row(
                  children: [
                    Text(
                      s.firstName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (s.kycVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: AppColors.info,
                      ),
                    ],
                  ],
                ),
                subtitle: s.ratingCount > 0
                    ? Row(
                        children: [
                          StarRating(value: s.ratingAvg.round(), size: 14),
                          const SizedBox(width: 6),
                          Text('(${s.ratingCount})'),
                        ],
                      )
                    : Text(l10n.newTraveler),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: s.id == null
                    ? null
                    : () => context.push(
                        '/user',
                        extra: BookingParty(
                          id: s.id!,
                          firstName: s.firstName,
                          ratingAvg: s.ratingAvg,
                          ratingCount: s.ratingCount,
                        ),
                      ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.teal),
                const SizedBox(width: 10),
                Expanded(child: Text(l10n.requestContactHint)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: scheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
