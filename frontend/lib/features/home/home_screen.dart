import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/language_menu.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Ungelesene Benachrichtigungen für das Badge laden.
    Future.microtask(
      () => ref.read(notificationsControllerProvider.notifier).load(),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: context.l10n.logout,
      message: context.l10n.logoutConfirm,
      confirmLabel: context.l10n.logout,
      destructive: true,
    );
    if (ok) ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unread = ref
        .watch(notificationsControllerProvider)
        .maybeWhen(
          data: (items) => items.where((n) => !n.isRead).length,
          orElse: () => 0,
        );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeroHeader(onLogout: () => _confirmLogout(context, ref)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.homeQuickActions,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.28,
              ),
              delegate: SliverChildListDelegate(
                <Widget>[
                  _ActionCard(
                    icon: Icons.search_rounded,
                    label: l10n.homeSearchTrips,
                    color: AppColors.teal,
                    onTap: () => context.go('/trips'),
                  ),
                  _ActionCard(
                    icon: Icons.flight_takeoff_rounded,
                    label: l10n.offerTripTitle,
                    color: AppColors.blue,
                    onTap: () => context.push('/trip/new'),
                  ),
                  _ActionCard(
                    icon: Icons.inbox_rounded,
                    label: l10n.homeRequestBoard,
                    color: AppColors.amberDeep,
                    onTap: () => context.push('/requests'),
                  ),
                  _ActionCard(
                    icon: Icons.add_box_rounded,
                    label: l10n.homePostRequest,
                    color: AppColors.tealDeep,
                    onTap: () => context.push('/request/new'),
                  ),
                  _ActionCard(
                    icon: Icons.luggage_rounded,
                    label: l10n.myTripsTitle,
                    color: AppColors.amberDeep,
                    onTap: () => context.push('/trips/mine'),
                  ),
                  _ActionCard(
                    icon: Icons.inventory_2_rounded,
                    label: l10n.homeMyBookings,
                    color: AppColors.success,
                    onTap: () => context.go('/bookings'),
                  ),
                  _ActionCard(
                    icon: Icons.notifications_rounded,
                    label: l10n.homeNotifications,
                    color: AppColors.info,
                    showBadge: true,
                    badgeCount: unread,
                    onTap: () => context.push('/notifications'),
                  ),
                  _ActionCard(
                    icon: Icons.verified_user_rounded,
                    label: l10n.homeVerify,
                    color: AppColors.danger,
                    onTap: () => context.push('/kyc'),
                  ),
                  _ActionCard(
                    icon: Icons.person_rounded,
                    label: l10n.profileTitle,
                    color: AppColors.tealDeep,
                    onTap: () => context.go('/profile'),
                  ),
                ].asMap().entries.map((e) {
                  return FadeSlideIn(index: e.key, child: e.value);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gefärbter Marken-Header mit Begrüßung, Sprache und Logout.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 8, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppLogo(size: 36, showWordmark: true, onDark: true),
                  const Spacer(),
                  Theme(
                    data: Theme.of(context).copyWith(
                      iconTheme: const IconThemeData(color: Colors.white),
                    ),
                    child: const LanguageMenu(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: l10n.logout,
                    onPressed: onLogout,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                l10n.homeWelcome,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.loginTagline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Eine Aktions-Kachel im Dashboard-Grid.
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.showBadge = false,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool showBadge;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final iconBox = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: color, size: 24),
    );
    return PressableScale(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nur die Benachrichtigungs-Kachel trägt ein Badge.
                if (showBadge)
                  Badge(
                    isLabelVisible: badgeCount > 0,
                    label: Text('$badgeCount'),
                    child: iconBox,
                  )
                else
                  iconBox,
                const SizedBox(height: 10),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
