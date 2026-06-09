import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import 'dispute_rules.dart';

/// Öffnet den Streitfall-Dialog. Gibt `true` zurück, wenn erfolgreich eröffnet.
Future<bool?> showDisputeDialog(BuildContext context, String bookingId) {
  return showDialog<bool>(
    context: context,
    builder: (_) => DisputeDialog(bookingId: bookingId),
  );
}

class DisputeDialog extends ConsumerStatefulWidget {
  const DisputeDialog({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<DisputeDialog> createState() => _DisputeDialogState();
}

class _DisputeDialogState extends ConsumerState<DisputeDialog> {
  final _reason = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reason.text.trim();
    if (reason.length < kDisputeReasonMinLength) {
      setState(() => _error = context.l10n.disputeReasonTooShort);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final error = await ref
        .read(disputeControllerProvider(widget.bookingId).notifier)
        .submit(reason);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _submitting = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.disputeTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.disputeHint),
          const SizedBox(height: 12),
          TextField(
            key: const Key('disputeReason'),
            controller: _reason,
            maxLines: 4,
            maxLength: 1000,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.disputeReasonHint,
              border: const OutlineInputBorder(),
              errorText: _error,
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
          key: const Key('submitDispute'),
          onPressed: _submitting ? null : _submit,
          child: Text(l10n.disputeSubmit),
        ),
      ],
    );
  }
}
