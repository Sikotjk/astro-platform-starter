import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(kycControllerProvider.notifier).refresh());
  }

  (Color, String) _statusStyle(BuildContext context, String status) {
    final scheme = Theme.of(context).colorScheme;
    return switch (status) {
      'VERIFIED' => (Colors.green, 'Verifiziert'),
      'PENDING' => (Colors.orange, 'In Prüfung'),
      'REJECTED' => (scheme.error, 'Abgelehnt'),
      _ => (scheme.outline, 'Nicht gestartet'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final kyc = ref.watch(kycControllerProvider);
    final (color, label) = _statusStyle(context, kyc.status);

    return Scaffold(
      appBar: AppBar(title: const Text('Identitätsprüfung')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, size: 64, color: color),
                const SizedBox(height: 16),
                Chip(
                  key: const Key('kycStatus'),
                  label: Text(label),
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Zum Anbieten von Trips ist eine einmalige Identitätsprüfung nötig.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (kyc.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      kyc.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (!kyc.isVerified)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: kyc.loading
                          ? null
                          : () => ref
                                .read(kycControllerProvider.notifier)
                                .startVerification(),
                      child: kyc.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              kyc.isPending
                                  ? 'Erneut starten'
                                  : 'Verifizierung starten',
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
