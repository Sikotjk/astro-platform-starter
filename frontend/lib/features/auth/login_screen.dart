import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../widgets/language_menu.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authControllerProvider.notifier)
          .login(email: _email.text.trim(), password: _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navLogin),
        actions: const [LanguageMenu()],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.appTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    key: const Key('email'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: l10n.fieldEmail),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? l10n.validEmail
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('password'),
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.fieldPassword),
                    validator: (v) =>
                        (v == null || v.length < 8) ? l10n.validPassword : null,
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
                          : Text(l10n.loginButton),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text(l10n.noAccount),
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
