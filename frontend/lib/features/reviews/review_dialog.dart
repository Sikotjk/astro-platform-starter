import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../widgets/star_rating.dart';

/// Öffnet den Bewertungs-Dialog. Gibt `true` zurück, wenn erfolgreich gesendet.
Future<bool?> showReviewDialog(BuildContext context, String bookingId) {
  return showDialog<bool>(
    context: context,
    builder: (_) => ReviewDialog(bookingId: bookingId),
  );
}

class ReviewDialog extends ConsumerStatefulWidget {
  const ReviewDialog({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends ConsumerState<ReviewDialog> {
  int _rating = 5;
  final _comment = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final error = await ref
        .read(reviewControllerProvider(widget.bookingId).notifier)
        .submit(rating: _rating, comment: _comment.text.trim());
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.reviewTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: StarRating(
              value: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('reviewComment'),
            controller: _comment,
            maxLines: 3,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: l10n.reviewCommentHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('submitReview'),
          onPressed: _submitting ? null : _submit,
          child: Text(l10n.reviewSubmit),
        ),
      ],
    );
  }
}
