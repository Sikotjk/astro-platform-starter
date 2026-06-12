import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/language_menu.dart';
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
  bool _obscure = true;

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
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const AppLogo(size: 34, showWordmark: true, onDark: true),
                      const Spacer(),
                      Theme(
                        data: Theme.of(context).copyWith(
                          iconTheme: const IconThemeData(color: Colors.white),
                        ),
                        child: const LanguageMenu(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.navRegister,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          key: const Key('firstName'),
                                          controller: _firstName,
                                          decoration: InputDecoration(
                                            labelText: l10n.fieldFirstName,
                                          ),
                                          validator: (v) =>
                                              (v == null || v.isEmpty)
                                              ? l10n.validRequired
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          key: const Key('lastName'),
                                          controller: _lastName,
                                          decoration: InputDecoration(
                                            labelText: l10n.fieldLastName,
                                          ),
                                          validator: (v) =>
                                              (v == null || v.isEmpty)
                                              ? l10n.validRequired
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    key: const Key('email'),
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: l10n.fieldEmail,
                                      prefixIcon: const Icon(
                                        Icons.mail_outline,
                                      ),
                                    ),
                                    validator: (v) =>
                                        (v == null || !v.contains('@'))
                                        ? l10n.validEmail
                                        : null,
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    key: const Key('password'),
                                    controller: _password,
                                    obscureText: _obscure,
                                    decoration: InputDecoration(
                                      labelText: l10n.fieldPassword,
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscure = !_obscure,
                                        ),
                                      ),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.length < 8)
                                        ? l10n.validPassword
                                        : null,
                                  ),
                                  const SizedBox(height: 14),
                                  DropdownButtonFormField<String>(
                                    key: const Key('role'),
                                    initialValue: _role,
                                    decoration: InputDecoration(
                                      labelText: l10n.roleLabel,
                                      prefixIcon: const Icon(
                                        Icons.badge_outlined,
                                      ),
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: 'SENDER',
                                        child: Text(l10n.roleSender),
                                      ),
                                      DropdownMenuItem(
                                        value: 'TRAVELER',
                                        child: Text(l10n.roleTraveler),
                                      ),
                                      DropdownMenuItem(
                                        value: 'BOTH',
                                        child: Text(l10n.roleBoth),
                                      ),
                                    ],
                                    onChanged: (v) =>
                                        setState(() => _role = v ?? 'SENDER'),
                                  ),
                                  if (auth.status == AuthStatus.error &&
                                      auth.error != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: scheme.errorContainer
                                              .withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.sm,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              size: 20,
                                              color: scheme.error,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                auth.error!,
                                                style: TextStyle(
                                                  color: scheme.error,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 24),
                                  FilledButton(
                                    onPressed: auth.isLoading ? null : _submit,
                                    child: auth.isLoading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.4,
                                            ),
                                          )
                                        : Text(l10n.registerButton),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
