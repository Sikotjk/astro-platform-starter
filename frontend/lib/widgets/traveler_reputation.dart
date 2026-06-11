import 'package:flutter/material.dart';

import '../core/l10n_ext.dart';
import '../models/trip.dart';
import 'star_rating.dart';

/// Kompakte Reputationsanzeige eines Reisenden (Name + Sterne/Anzahl).
/// Reisende ohne Bewertung erhalten eine „Neu"-Kennzeichnung.
class TravelerReputation extends StatelessWidget {
  const TravelerReputation({super.key, required this.traveler});

  final TripTraveler traveler;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasReviews = traveler.ratingCount > 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          traveler.firstName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        if (!hasReviews)
          Chip(
            label: Text(l10n.newTraveler),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            labelStyle: Theme.of(context).textTheme.labelSmall,
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StarRating(value: traveler.ratingAvg.round(), size: 14),
              const SizedBox(width: 4),
              Text(
                '${traveler.ratingAvg.toStringAsFixed(1)} '
                '(${traveler.ratingCount})',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}
