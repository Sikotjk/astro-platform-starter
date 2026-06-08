import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      (v == null || v.trim().isEmpty) ? 'Pflichtfeld' : null;
  String? _number(String? v) =>
      (double.tryParse((v ?? '').trim()) ?? 0) > 0 ? null : 'Zahl > 0 eingeben';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createBookingControllerProvider);

    ref.listen<CreateBookingState>(createBookingControllerProvider, (_, next) {
      if (next.status == CreateStatus.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Buchung angefragt!')));
        context.go('/bookings');
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Buchen · ${widget.trip.route}')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Abflug ${widget.trip.departureDate} · ${widget.trip.pricePerKg.toStringAsFixed(2)} ${widget.trip.currency}/kg',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Divider(height: 24),
              TextFormField(
                key: const Key('title'),
                controller: _title,
                decoration: const InputDecoration(labelText: 'Pakettitel'),
                validator: _required,
              ),
              TextFormField(
                key: const Key('weight'),
                controller: _weight,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Gewicht (kg)'),
                validator: _number,
              ),
              TextFormField(
                key: const Key('value'),
                controller: _value,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Warenwert (EUR)'),
                validator: _number,
              ),
              const SizedBox(height: 12),
              Text('Empfänger', style: Theme.of(context).textTheme.titleSmall),
              TextFormField(
                key: const Key('recipientName'),
                controller: _recipientName,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _required,
              ),
              TextFormField(
                key: const Key('recipientPhone'),
                controller: _recipientPhone,
                decoration: const InputDecoration(labelText: 'Telefon'),
                validator: _required,
              ),
              TextFormField(
                key: const Key('recipientCity'),
                controller: _recipientCity,
                decoration: const InputDecoration(labelText: 'Stadt'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              Text(
                'Inhalt (Zoll-Deklaration)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              DropdownButtonFormField<String>(
                key: const Key('category'),
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Kategorie'),
                items: [
                  for (final c in customsCategories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'OTHER'),
              ),
              TextFormField(
                key: const Key('itemDescription'),
                controller: _itemDescription,
                decoration: const InputDecoration(labelText: 'Beschreibung'),
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'Mind. 3 Zeichen'
                    : null,
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
                    : const Text('Buchung anfragen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
