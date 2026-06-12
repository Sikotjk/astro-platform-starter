import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/customs.dart';
import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../models/package.dart';
import '../../models/package_request.dart';

class PostRequestScreen extends ConsumerStatefulWidget {
  const PostRequestScreen({super.key});

  @override
  ConsumerState<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends ConsumerState<PostRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _origin = TextEditingController();
  final _destination = TextEditingController();
  final _weight = TextEditingController();
  final _reward = TextEditingController();
  final _notes = TextEditingController();
  String _category = 'OTHER';
  bool _submitting = false;

  @override
  void dispose() {
    for (final c in [_title, _origin, _destination, _weight, _reward, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _iata(String? v) =>
      (v == null || v.trim().length != 3) ? context.l10n.validIata : null;

  String? _positive(String? v) => (double.tryParse((v ?? '').trim()) ?? 0) > 0
      ? null
      : context.l10n.validNumber;

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? context.l10n.validRequired : null;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final error = await ref
        .read(createRequestControllerProvider.notifier)
        .submit(
          CreateRequestInput(
            title: _title.text.trim(),
            originAirport: _origin.text.trim(),
            destinationAirport: _destination.text.trim(),
            weightKg: double.parse(_weight.text.trim()),
            rewardOffered: double.parse(_reward.text.trim()),
            category: _category,
            notes: _notes.text.trim(),
          ),
        );
    if (!mounted) return;
    if (error != null) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ref.read(requestsControllerProvider.notifier).search();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.requestPublished)));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final iata = <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
      LengthLimitingTextInputFormatter(3),
    ];
    final number = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.postRequestTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('reqTitle'),
              controller: _title,
              decoration: InputDecoration(
                labelText: l10n.fieldPackageTitle,
                prefixIcon: const Icon(Icons.title),
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const Key('reqFrom'),
                    controller: _origin,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: iata,
                    decoration: InputDecoration(
                      labelText: l10n.fieldFrom,
                      hintText: 'FRA',
                    ),
                    validator: _iata,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    key: const Key('reqTo'),
                    controller: _destination,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: iata,
                    decoration: InputDecoration(
                      labelText: l10n.fieldTo,
                      hintText: 'DYU',
                    ),
                    validator: _iata,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const Key('reqWeight'),
                    controller: _weight,
                    keyboardType: TextInputType.number,
                    inputFormatters: number,
                    decoration: InputDecoration(
                      labelText: l10n.fieldWeightKg,
                      prefixIcon: const Icon(Icons.scale),
                    ),
                    validator: _positive,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    key: const Key('reqReward'),
                    controller: _reward,
                    keyboardType: TextInputType.number,
                    inputFormatters: number,
                    decoration: InputDecoration(
                      labelText: l10n.fieldReward,
                      prefixIcon: const Icon(Icons.savings_outlined),
                    ),
                    validator: _positive,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('reqCategory'),
              initialValue: _category,
              decoration: InputDecoration(
                labelText: l10n.fieldCategory,
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              items: [
                for (final c in customsCategories)
                  DropdownMenuItem(
                    value: c,
                    child: Text(customsCategoryLabel(l10n, c)),
                  ),
              ],
              onChanged: (v) => setState(() => _category = v ?? 'OTHER'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('reqNotes'),
              controller: _notes,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.fieldNotesOptional,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('submitRequest'),
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : Text(l10n.postRequestTitle),
            ),
          ],
        ),
      ),
    );
  }
}
