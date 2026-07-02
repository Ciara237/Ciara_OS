import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/sidebar_navigation_utils.dart';
import 'package:ciaraos/widgets/common/user_avatar_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _headerGroupGap = 12.0;
const _headerActionSize = 40.0;

class TodayHeader extends StatelessWidget {
  const TodayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: AppSpacing.appBarHeight,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: _headerActionSize,
            child: UserAvatarButton(
              size: _headerActionSize,
              onTap: () => handleAvatarNavigation(context),
            ),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.terminal, color: colorScheme.primary, size: 24),
                  const SizedBox(width: _headerGroupGap),
                  Text(
                    'Ciara OS',
                    style: AppTypography.headingMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: _headerActionSize,
            child: IconButton(
              onPressed: () => context.push('/settings'),
              icon: Icon(
                Icons.settings_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 24,
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              constraints: const BoxConstraints(
                minWidth: _headerActionSize,
                minHeight: _headerActionSize,
              ),
              style: IconButton.styleFrom(
                shape: const CircleBorder(),
              ),
              tooltip: 'Settings',
            ),
          ),
        ],
      ),
    );
  }
}
