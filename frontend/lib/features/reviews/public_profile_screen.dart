import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../models/booking_detail.dart';
import '../../models/review.dart';
import '../../widgets/error_retry.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/user_avatar.dart';

/// Öffentliches Profil einer Gegenpartei: Name + Reputation + Bewertungen.
/// Bekommt die Stammdaten als [party] übergeben und lädt die Bewertungen nach.
class PublicProfileScreen extends ConsumerStatefulWidget {
  const PublicProfileScreen({super.key, required this.party});

  final BookingParty party;

  @override
  ConsumerState<PublicProfileScreen> createState() =>
      _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(userReviewsControllerProvider(widget.party.id).notifier)
          .load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = widget.party;
    final state = ref.watch(userReviewsControllerProvider(p.id));
    final hasReviews = p.ratingCount > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.firstName.isEmpty ? l10n.bookingPartner : p.firstName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              UserAvatar(name: p.firstName, url: p.avatarUrl, radius: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.firstName.isEmpty ? l10n.bookingPartner : p.firstName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (hasReviews) ...[
                          StarRating(value: p.ratingAvg.round(), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${p.ratingAvg.toStringAsFixed(1)} '
                            '(${l10n.reviewsCount(p.ratingCount)})',
                          ),
                        ] else
                          Text(l10n.newTraveler),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Text(
            l10n.reviewsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          state.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => ErrorRetry(
              message: e.toString(),
              onRetry: () =>
                  ref.read(userReviewsControllerProvider(p.id).notifier).load(),
            ),
            data: (reviews) => reviews.isEmpty
                ? Text(l10n.noReviews)
                : Column(
                    children: [for (final r in reviews) _ReviewTile(review: r)],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            name: review.authorName,
            url: review.authorAvatarUrl,
            radius: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StarRating(value: review.rating, size: 16),
                    const Spacer(),
                    Text(
                      context.formatDate(review.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Text(
                  review.authorName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (review.comment != null && review.comment!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(review.comment!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
