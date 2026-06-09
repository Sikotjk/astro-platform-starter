import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../models/auth.dart';
import '../../models/review.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/star_rating.dart';
import 'profile_controller.dart';

/// Lokalisierte Rollenbezeichnung.
String roleLabel(AppLocalizations l10n, String role) {
  return switch (role) {
    'SENDER' => l10n.roleSender,
    'TRAVELER' => l10n.roleTraveler,
    'BOTH' => l10n.roleBoth,
    _ => role,
  };
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileControllerProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(profileControllerProvider);

    final profile = state.value?.profile;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          if (profile != null)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: l10n.editProfile,
              onPressed: () => context.push('/profile/edit', extra: profile),
            ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetry(
          message: e.toString(),
          onRetry: () => ref.read(profileControllerProvider.notifier).load(),
        ),
        data: (data) => _ProfileBody(data: data),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.data});

  final ProfileData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final UserProfile p = data.profile;
    final List<Review> reviews = data.reviews;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Header(profile: p),
        const Divider(height: 32),
        Text(l10n.reviewsTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (reviews.isEmpty)
          Text(l10n.noReviews)
        else
          for (final r in reviews) _ReviewTile(review: r),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = '${profile.firstName} ${profile.lastName}'.trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 32,
          child: Text(
            (profile.firstName.isNotEmpty ? profile.firstName[0] : '?')
                .toUpperCase(),
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? profile.email : name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(roleLabel(l10n, profile.role)),
              const SizedBox(height: 8),
              Row(
                children: [
                  StarRating(value: profile.ratingAvg.round(), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    profile.ratingCount == 0
                        ? l10n.noReviews
                        : '${profile.ratingAvg.toStringAsFixed(1)} '
                              '(${l10n.reviewsCount(profile.ratingCount)})',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _KycChip(status: profile.kycStatus),
            ],
          ),
        ),
      ],
    );
  }
}

class _KycChip extends StatelessWidget {
  const _KycChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, color) = switch (status) {
      'VERIFIED' => (l10n.kycVerified, Colors.green),
      'PENDING' => (l10n.kycPending, Colors.orange),
      'REJECTED' => (l10n.kycRejected, Colors.red),
      _ => (l10n.kycNotStarted, Colors.grey),
    };
    return Chip(
      avatar: Icon(Icons.verified_user, size: 18, color: color),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final d = review.createdAt.toLocal();
    final date =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StarRating(value: review.rating, size: 16),
              const Spacer(),
              Text(
                '${review.authorName} · $date',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(review.comment!),
            ),
        ],
      ),
    );
  }
}
