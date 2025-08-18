import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ReleaseMinigame extends StatefulWidget {
  const ReleaseMinigame({super.key});

  @override
  State<ReleaseMinigame> createState() => _ReleaseMinigameState();
}

class _ReleaseMinigameState extends State<ReleaseMinigame> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _slide = Tween<Offset>(begin: const Offset(-1, 0), end: const Offset(1.2, 0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.releaseMinigame)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SlideTransition(
                position: _slide,
                child: const Text('🦊', style: TextStyle(fontSize: 64)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _controller.forward(from: 0);
                if (mounted) _showSuccess(context);
              },
              child: Text(l10n.releaseMinigame),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context) {
    final l10n = L10n.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.congratsRescue),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}