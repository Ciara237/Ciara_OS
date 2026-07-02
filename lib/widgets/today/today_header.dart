import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/common/user_avatar_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _headerGroupGap = 12.0;
const _headerActionSize = 40.0;

class TodayHeader extends StatelessWidget {
  const TodayHeader({super.key});

  void _openDrawer(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.hasDrawer ?? false) {
      scaffold!.openDrawer();
    }
  }

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
          UserAvatarButton(
            size: _headerActionSize,
            onTap: () => _openDrawer(context),
          ),
          const SizedBox(width: _headerGroupGap),
          Icon(Icons.terminal, color: colorScheme.primary, size: 24),
          const SizedBox(width: _headerGroupGap),
          Text(
            'Ciara OS',
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(
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
        ],
      ),
    );
  }
}
