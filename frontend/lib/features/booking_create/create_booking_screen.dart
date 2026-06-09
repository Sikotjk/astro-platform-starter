import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/customs.dart';
import '../../core/formatting.dart';
import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../models/package.dart';
import '../../models/trip.dart';
import 'create_booking_controller.dart';

class CreateBookingScreen extends ConsumerStatefulWidget {
  const CreateBookingScreen({super.key, required this.trip});

  final Trip trip;

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _weight = TextEditingController();
  final _value = TextEditingController();
  final _recipientName = TextEditingController();
  final _recipientPhone = TextEditingController();
  final _recipientCity = TextEditingController();
  final _itemDescription = TextEditingController();
  String _category = 'CLOTHING';

  @override
  void dispose() {
    for (final c in [
      _title,
      _weight,
      _value,
      _recipientName,
      _recipientPhone,
      _recipientCity,
      _itemDescription,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final weight = double.tryParse(_weight.text.trim()) ?? 0;
    final value = double.tryParse(_value.text.trim()) ?? 0;

    ref
        .read(createBookingControllerProvider.notifier)
        .submit(
          tripId: widget.trip.id,
          agreedWeightKg: weight,
          package: CreatePackageRequest(
            title: _title.text.trim(),
            weightKg: weight,
            declaredValueEur: value,
            recipientName: _recipientName.text.trim(),
            recipientPhone: _recipientPhone.text.trim(),
            recipientCity: _recipientCity.text.trim(),
            items: [
              DeclarationItemInput(
                category: _category,
                description: _itemDescription.text.trim(),
                quantity: 1,
                unitValueEur: value,
              ),
            ],
          ),
        );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? context.l10n.validRequired : null;
  String? _number(String? v) => (double.tryParse((v ?? '').trim()) ?? 0) > 0
      ? null
      : context.l10n.validNumber;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createBookingControllerProvider);
    final l10n = context.l10n;

    ref.listen<CreateBookingState>(createBookingControllerProvider, (_, next) {
      if (next.status == CreateStatus.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.bookingRequested)));
        context.go('/bookings');
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookTitle(widget.trip.route))),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.bookTripInfo(
                  context.formatDate(widget.trip.departureAt),
                  widget.trip.pricePerKg.toStringAsFixed(2),
                  widget.trip.currency,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Divider(height: 24),
              TextFormField(
                key: const Key('title'),
                controller: _title,
                decoration: InputDecoration(labelText: l10n.fieldPackageTitle),
                validator: _required,
              ),
              TextFormField(
                key: const Key('weight'),
                controller: _weight,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.fieldWeightKg),
                validator: _number,
              ),
              TextFormField(
                key: const Key('value'),
                controller: _value,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.fieldDeclaredValue),
                validator: _number,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.recipientSection,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextFormField(
                key: const Key('recipientName'),
                controller: _recipientName,
                decoration: InputDecoration(labelText: l10n.fieldName),
                validator: _required,
              ),
              TextFormField(
                key: const Key('recipientPhone'),
                controller: _recipientPhone,
                decoration: InputDecoration(labelText: l10n.fieldPhone),
                validator: _required,
              ),
              TextFormField(
                key: const Key('recipientCity'),
                controller: _recipientCity,
                decoration: InputDecoration(labelText: l10n.fieldCity),
                validator: _required,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.contentSection,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              DropdownButtonFormField<String>(
                key: const Key('category'),
                initialValue: _category,
                decoration: InputDecoration(labelText: l10n.fieldCategory),
                items: [
                  for (final c in customsCategories)
                    DropdownMenuItem(
                      value: c,
                      child: Text(customsCategoryLabel(l10n, c)),
                    ),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'OTHER'),
              ),
              TextFormField(
                key: const Key('itemDescription'),
                controller: _itemDescription,
                decoration: InputDecoration(labelText: l10n.fieldDescription),
                validator: (v) =>
                    (v == null || v.trim().length < 3) ? l10n.validMin3 : null,
              ),
              const SizedBox(height: 24),
              if (state.status == CreateStatus.error && state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    state.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              FilledButton(
                onPressed: state.isLoading ? null : _submit,
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.bookButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
