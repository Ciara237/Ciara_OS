import 'package:ciaraos/providers/profile_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/sidebar_navigation_utils.dart';
import 'package:ciaraos/widgets/common/user_avatar_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _drawerWidth = 280.0;
const _activeBorderWidth = 3.0;
const _appVersion = 'v1.0.0';
const _drawerAvatarSize = 48.0;

class PrimaryDrawer extends ConsumerWidget {
  const PrimaryDrawer({super.key});

  String _currentLocation(BuildContext context) {
    final configuration =
        GoRouter.of(context).routerDelegate.currentConfiguration;
    if (configuration.isEmpty) {
      return GoRouterState.of(context).uri.path;
    }
    return configuration.last.matchedLocation;
  }

  void _navigate(BuildContext context, String route) {
    context.go(route);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentRoute = _currentLocation(context);
    final profile = ref.watch(profileProvider);

    return Drawer(
      width: _drawerWidth,
      backgroundColor: colorScheme.surfaceContainerLow,
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(
              displayName: profile.resolvedDisplayName,
              tagline: profile.tagline,
              onAvatarTap: () => handleDrawerAvatarNavigation(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  0,
                  AppSpacing.sm,
                  AppSpacing.md,
                ),
                children: [
                  _DrawerSection(
                    title: 'SKILLS',
                    children: [
                      _DrawerItem(
                        label: 'GitHub Activity',
                        icon: Icons.code,
                        route: '/skills/github',
                        currentRoute: currentRoute,
                        onTap: () => _navigate(context, '/skills/github'),
                      ),
                      _DrawerItem(
                        label: 'Security Practice',
                        icon: Icons.security,
                        route: '/skills/ctf',
                        currentRoute: currentRoute,
                        onTap: () => _navigate(context, '/skills/ctf'),
                      ),
                      _DrawerItem(
                        label: 'Certifications',
                        icon: Icons.workspace_premium,
                        route: '/skills/certifications',
                        currentRoute: currentRoute,
                        onTap: () =>
                            _navigate(context, '/skills/certifications'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DrawerSection(
                    title: 'ANALYTICS',
                    children: [
                      _DrawerItem(
                        label: 'Productivity Trends',
                        icon: Icons.bar_chart,
                        route: '/analytics/trends',
                        currentRoute: currentRoute,
                        onTap: () => _navigate(context, '/analytics/trends'),
                      ),
                      _DrawerItem(
                        label: 'Domain Breakdown',
                        icon: Icons.donut_large,
                        route: '/analytics/domains',
                        currentRoute: currentRoute,
                        onTap: () => _navigate(context, '/analytics/domains'),
                      ),
                      _DrawerItem(
                        label: 'Planning Accuracy',
                        icon: Icons.track_changes,
                        route: '/analytics/accuracy',
                        currentRoute: currentRoute,
                        onTap: () => _navigate(context, '/analytics/accuracy'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DrawerSection(
                    title: 'KNOWLEDGE',
                    children: [
                      _DrawerItem(
                        label: 'Notes',
                        icon: Icons.description,
                        route: '/knowledge/notes',
                        currentRoute: currentRoute,
                        onTap: () => _navigate(context, '/knowledge/notes'),
                      ),
                      _DrawerItem(
                        label: 'Resources',
                        icon: Icons.bookmark,
                        route: '/knowledge/resources',
                        currentRoute: currentRoute,
                        onTap: () => _navigate(context, '/knowledge/resources'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DrawerSection(
                    title: 'PERSONAL',
                    children: [
                      _DrawerItem(
                        label: 'Profile',
                        icon: Icons.person,
                        route: '/profile',
                        currentRoute: currentRoute,
                        onTap: () => _navigate(context, '/profile'),
                      ),
                      _DrawerItem(
                        label: 'Settings',
                        icon: Icons.settings,
                        route: '/settings',
                        currentRoute: currentRoute,
                        onTap: () => _navigate(context, '/settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const _DrawerFooter(),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.displayName,
    required this.tagline,
    required this.onAvatarTap,
  });

  final String displayName;
  final String tagline;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              UserAvatarButton(
                size: _drawerAvatarSize,
                onTap: onAvatarTap,
                tooltip: 'Go to Today',
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headingMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      tagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.currentRoute,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;

  bool get _isActive {
    return currentRoute == route || currentRoute.startsWith('$route/');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = _isActive;
    final foreground =
        isActive ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: isActive ? colorScheme.surfaceContainerHigh : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            decoration: isActive
                ? BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: colorScheme.primary,
                        width: _activeBorderWidth,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  )
                : null,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(icon, color: foreground, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.monospace.copyWith(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w400,
                      color: foreground,
                      decoration: TextDecoration.none,
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

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _appVersion,
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            'Ciara OS',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
