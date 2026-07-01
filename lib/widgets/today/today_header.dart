import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: AppSpacing.appBarHeight,
      color: colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Icon(Icons.terminal, color: colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Ciara OS',
            style: AppTypography.monospace.copyWith(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/profile'),
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                radius: AppSpacing.md,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  'CM',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
