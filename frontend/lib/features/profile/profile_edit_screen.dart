import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n_ext.dart';
import '../../core/locale_controller.dart';
import '../../core/providers.dart';
import '../../models/auth.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late String _locale;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.profile.firstName);
    _lastName = TextEditingController(text: widget.profile.lastName);
    _locale =
        LocaleController.supported.contains(widget.profile.preferredLocale)
        ? widget.profile.preferredLocale
        : 'de';
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final error = await ref
        .read(profileControllerProvider.notifier)
        .update(
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          preferredLocale: _locale,
        );
    if (!mounted) return;
    if (error != null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    // App-Sprache an die gespeicherte Präferenz angleichen.
    ref.read(localeProvider.notifier).setLanguage(_locale);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.profileSaved)));
    final nav = Navigator.of(context);
    if (nav.canPop()) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('firstName'),
                controller: _firstName,
                decoration: InputDecoration(labelText: l10n.fieldFirstName),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.validRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('lastName'),
                controller: _lastName,
                decoration: InputDecoration(labelText: l10n.fieldLastName),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.validRequired : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: const Key('locale'),
                initialValue: _locale,
                decoration: InputDecoration(labelText: l10n.language),
                items: [
                  DropdownMenuItem(value: 'de', child: Text(l10n.langDe)),
                  DropdownMenuItem(value: 'ru', child: Text(l10n.langRu)),
                  DropdownMenuItem(value: 'tg', child: Text(l10n.langTj)),
                ],
                onChanged: (v) => setState(() => _locale = v ?? _locale),
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('saveProfile'),
                onPressed: _saving ? null : _save,
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
