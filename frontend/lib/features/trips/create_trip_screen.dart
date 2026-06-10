import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatting.dart';
import '../../core/l10n_ext.dart';
import '../../core/providers.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _origin = TextEditingController();
  final _destination = TextEditingController();
  final _capacity = TextEditingController();
  final _price = TextEditingController();
  DateTime? _departure;
  bool _departureTouched = false;
  bool _submitting = false;

  @override
  void dispose() {
    _origin.dispose();
    _destination.dispose();
    _capacity.dispose();
    _price.dispose();
    super.dispose();
  }

  String? _iata(String? v) =>
      (v == null || v.trim().length != 3) ? context.l10n.validIata : null;

  String? _positive(String? v) => (double.tryParse((v ?? '').trim()) ?? 0) > 0
      ? null
      : context.l10n.validNumber;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: now.add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _departure = picked);
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    if (_departure == null) setState(() => _departureTouched = true);
    if (!formOk || _departure == null) return;

    setState(() => _submitting = true);
    final error = await ref
        .read(createTripControllerProvider.notifier)
        .submit(
          originAirport: _origin.text.trim(),
          destinationAirport: _destination.text.trim(),
          departureAt: _departure!,
          capacityKgTotal: double.parse(_capacity.text.trim()),
          pricePerKg: double.parse(_price.text.trim()),
        );
    if (!mounted) return;
    if (error != null) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.tripPublished)));
    context.go('/trips');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final iataFormatters = <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
      LengthLimitingTextInputFormatter(3),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.offerTripTitle)),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('origin'),
                controller: _origin,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: iataFormatters,
                decoration: InputDecoration(
                  labelText: l10n.fieldFrom,
                  hintText: 'FRA',
                ),
                validator: _iata,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('destination'),
                controller: _destination,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: iataFormatters,
                decoration: InputDecoration(
                  labelText: l10n.fieldTo,
                  hintText: 'DYU',
                ),
                validator: _iata,
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.fieldDeparture,
                  errorText: (_departureTouched && _departure == null)
                      ? l10n.validRequired
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _departure == null
                          ? '—'
                          : context.formatDate(_departure!),
                    ),
                    TextButton.icon(
                      key: const Key('pickDate'),
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(l10n.pickDate),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('capacity'),
                controller: _capacity,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(labelText: l10n.fieldCapacityKg),
                validator: _positive,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('price'),
                controller: _price,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(labelText: l10n.fieldPricePerKg),
                validator: _positive,
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('publishTrip'),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.publishTrip),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.offerTripKycHint,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
