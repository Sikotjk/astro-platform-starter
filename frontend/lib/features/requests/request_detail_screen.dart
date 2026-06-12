import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/customs.dart';
import '../../core/formatting.dart';
import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../models/booking_detail.dart';
import '../../models/package_request.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/user_avatar.dart';

/// Detailansicht eines Liefer-Wunsches vom Board.
///
/// Eigentümer (Sender) sehen die eingegangenen Angebote und können eines
/// annehmen. Andere Nutzer können als Reisende auf den Wunsch reagieren.
class RequestDetailScreen extends ConsumerStatefulWidget {
  const RequestDetailScreen({super.key, required this.request});

  final PackageRequest request;

  @override
  ConsumerState<RequestDetailScreen> createState() =>
      _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  bool _offerSent = false;

  PackageRequest get r => widget.request;

  /// Eigentümer, wenn der Sender ich bin — oder wenn kein Sender geliefert
  /// wurde (Navigation aus „Meine Wünsche" zeigt nur eigene).
  bool _isOwner(String? myId) =>
      r.sender == null || (myId != null && r.sender!.id == myId);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final myId = ref.read(authControllerProvider).session?.userId;
      if (_isOwner(myId)) {
        ref.read(requestOffersControllerProvider(r.id).notifier).load();
      }
    });
  }

  Future<void> _makeOffer() async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.reactToRequest),
        content: TextField(
          key: const Key('offerMessage'),
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: l10n.makeOfferHint,
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.offerSend),
          ),
        ],
      ),
    );
    final message = controller.text.trim();
    controller.dispose();
    if (ok != true || !mounted) return;

    final error = await ref
        .read(makeOfferControllerProvider(r.id).notifier)
        .submit(message: message.isEmpty ? null : message);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _offerSent = true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.offerSent)));
  }

  Future<void> _accept(String offerId) async {
    final error = await ref
        .read(requestOffersControllerProvider(r.id).notifier)
        .accept(offerId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? context.l10n.offerAcceptedSnack)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final myId = ref.watch(authControllerProvider).session?.userId;
    final isOwner = _isOwner(myId);
    final s = r.sender;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.requestDetailTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(request: r),
          const SizedBox(height: 12),
          _FactsCard(request: r),
          if (s != null && !isOwner) ...[
            const SizedBox(height: 12),
            _SenderCard(sender: s),
          ],
          const SizedBox(height: 16),
          if (isOwner)
            _OwnerOffers(requestId: r.id, onAccept: _accept)
          else
            _TravelerActions(
              request: r,
              offerSent: _offerSent,
              onReact: _makeOffer,
            ),
        ],
      ),
    );
  }
}

// ── Reisenden-Sicht: reagieren ───────────────────────────────────────────────
class _TravelerActions extends StatelessWidget {
  const _TravelerActions({
    required this.request,
    required this.offerSent,
    required this.onReact,
  });

  final PackageRequest request;
  final bool offerSent;
  final VoidCallback onReact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (request.status != 'OPEN') {
      return _InfoBox(
        icon: Icons.lock_outline,
        text: l10n.requestAlreadyMatched,
      );
    }
    if (offerSent) {
      return _InfoBox(icon: Icons.check_circle_outline, text: l10n.offerSent);
    }
    return Column(
      children: [
        FilledButton.icon(
          key: const Key('reactButton'),
          onPressed: onReact,
          icon: const Icon(Icons.handshake_outlined),
          label: Text(l10n.reactToRequest),
        ),
        const SizedBox(height: 12),
        _InfoBox(icon: Icons.info_outline, text: l10n.requestContactHint),
      ],
    );
  }
}

// ── Eigentümer-Sicht: Angebote ───────────────────────────────────────────────
class _OwnerOffers extends ConsumerWidget {
  const _OwnerOffers({required this.requestId, required this.onAccept});

  final String requestId;
  final void Function(String offerId) onAccept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(requestOffersControllerProvider(requestId));

    return state.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _InfoBox(icon: Icons.error_outline, text: e.toString()),
      data: (offers) {
        if (offers.isEmpty) {
          return _InfoBox(icon: Icons.inbox_outlined, text: l10n.noOffers);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.offersTitle} (${offers.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            for (final o in offers)
              _OfferCard(offer: o, onAccept: () => onAccept(o.id)),
          ],
        );
      },
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer, required this.onAccept});

  final RequestOffer offer;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final t = offer.traveler;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(name: t?.firstName ?? '?', radius: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            t?.firstName ?? '—',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (t?.kycVerified ?? false) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: AppColors.info,
                            ),
                          ],
                        ],
                      ),
                      if ((t?.ratingCount ?? 0) > 0)
                        Row(
                          children: [
                            StarRating(value: t!.ratingAvg.round(), size: 13),
                            const SizedBox(width: 4),
                            Text(
                              '(${t.ratingCount})',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (offer.isAccepted)
                  _StatusPill(
                    label: l10n.offerAccepted,
                    color: AppColors.success,
                  )
                else if (offer.isDeclined)
                  _StatusPill(label: l10n.offerDeclined, color: scheme.outline),
              ],
            ),
            if (offer.message != null && offer.message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(offer.message!),
            ],
            if (!offer.isAccepted && !offer.isDeclined) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: Key('accept_${offer.id}'),
                  onPressed: onAccept,
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(l10n.acceptOffer),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ── Bausteine ────────────────────────────────────────────────────────────────
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.request});

  final PackageRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = request;
    return Card(
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
                const Icon(Icons.flight_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(r.route, style: const TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.rewardLabel,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                ),
                const Spacer(),
                Text(
                  '+${r.rewardOffered.toStringAsFixed(2)} ${r.currency}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FactsCard extends StatelessWidget {
  const _FactsCard({required this.request});

  final PackageRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = request;
    return Card(
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
    );
  }
}

class _SenderCard extends StatelessWidget {
  const _SenderCard({required this.sender});

  final RequestSender sender;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = sender;
    return Card(
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
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.teal),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
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
