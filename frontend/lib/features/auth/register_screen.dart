import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  String _role = 'SENDER';

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authControllerProvider.notifier)
          .register(
            email: _email.text.trim(),
            password: _password.text,
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            role: _role,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrieren')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: const Key('firstName'),
                    controller: _firstName,
                    decoration: const InputDecoration(labelText: 'Vorname'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Pflichtfeld' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('lastName'),
                    controller: _lastName,
                    decoration: const InputDecoration(labelText: 'Nachname'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Pflichtfeld' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('email'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-Mail'),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Gültige E-Mail eingeben'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('password'),
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Passwort'),
                    validator: (v) => (v == null || v.length < 8)
                        ? 'Mindestens 8 Zeichen'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: const Key('role'),
                    initialValue: _role,
                    decoration: const InputDecoration(
                      labelText: 'Ich möchte …',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'SENDER',
                        child: Text('Pakete senden'),
                      ),
                      DropdownMenuItem(
                        value: 'TRAVELER',
                        child: Text('Platz anbieten'),
                      ),
                      DropdownMenuItem(value: 'BOTH', child: Text('Beides')),
                    ],
                    onChanged: (v) => setState(() => _role = v ?? 'SENDER'),
                  ),
                  const SizedBox(height: 24),
                  if (auth.status == AuthStatus.error && auth.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        auth.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: auth.isLoading ? null : _submit,
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Konto erstellen'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
