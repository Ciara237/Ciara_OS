import 'package:ciaraos/providers/calendar_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/sidebar_navigation_utils.dart';
import 'package:ciaraos/widgets/calendar/calendar_setup_sheet.dart';
import 'package:ciaraos/widgets/common/user_avatar_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _headerGroupGap = 12.0;
const _headerActionSize = 40.0;

class TodayHeader extends ConsumerWidget {
  const TodayHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final authAsync = ref.watch(calendarAuthProvider);
    final authorized = authAsync.value?.authorized ?? false;

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
            child: IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(
                Icons.menu,
                color: colorScheme.onSurfaceVariant,
                size: 24,
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              constraints: const BoxConstraints(
                minWidth: _headerActionSize,
                minHeight: _headerActionSize,
              ),
              tooltip: 'Menu',
            ),
          ),
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
            onPressed: () => context.push('/daily-brief'),
            icon: Icon(
              Icons.rocket_launch,
              color: colorScheme.onSurfaceVariant,
              size: 24,
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            constraints: const BoxConstraints(
              minWidth: _headerActionSize,
              minHeight: _headerActionSize,
            ),
            tooltip: 'Daily Brief',
          ),
          IconButton(
            onPressed: () {
              if (authorized) {
                context.push('/calendar');
              } else {
                showCalendarSetupSheet(context, ref);
              }
            },
            icon: Icon(
              Icons.calendar_month,
              color: colorScheme.onSurfaceVariant,
              size: 24,
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            constraints: const BoxConstraints(
              minWidth: _headerActionSize,
              minHeight: _headerActionSize,
            ),
            tooltip: 'Calendar',
          ),
          SizedBox(
            width: _headerActionSize,
            child: UserAvatarButton(
              size: _headerActionSize,
              onTap: () => handleAvatarNavigation(context),
            ),
          ),
        ],
      ),
    );
  }
}
