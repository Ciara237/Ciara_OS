import 'package:ciaraos/providers/navigation_provider.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PrimaryNavDestination {
  const PrimaryNavDestination({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

const kPrimaryNavDestinations = [
  PrimaryNavDestination(
    label: 'Today',
    icon: Icons.calendar_today,
    route: '/',
  ),
  PrimaryNavDestination(
    label: 'Backlog',
    icon: Icons.list_alt,
    route: '/tasks',
  ),
  PrimaryNavDestination(
    label: 'Projects',
    icon: Icons.grid_view,
    route: '/projects',
  ),
  PrimaryNavDestination(
    label: 'Pipeline',
    icon: Icons.rocket_launch,
    route: '/opportunities',
  ),
  PrimaryNavDestination(
    label: 'Review',
    icon: Icons.bar_chart,
    route: '/review',
  ),
];

class PrimaryNavBar extends ConsumerWidget {
  const PrimaryNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedIndex = ref.watch(selectedTabProvider);

    return NavigationBar(
      height: AppSpacing.bottomNavHeight,
      backgroundColor: colorScheme.surfaceContainerLow,
      indicatorColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        ref.read(selectedTabProvider.notifier).state = index;
        context.go(kPrimaryNavDestinations[index].route);
      },
      destinations: [
        for (final destination in kPrimaryNavDestinations)
          NavigationDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(
              destination.icon,
              color: colorScheme.primary,
            ),
            label: destination.label,
          ),
      ],
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.labelSmall.copyWith(color: colorScheme.primary);
        }
        return AppTypography.labelSmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        );
      }),
    );
  }
}
