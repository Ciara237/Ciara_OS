import 'package:ciaraos/providers/calendar_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/sidebar_navigation_utils.dart';
import 'package:ciaraos/widgets/calendar/calendar_setup_sheet.dart';
import 'package:ciaraos/widgets/common/user_avatar_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TodayHeader extends ConsumerWidget {
  const TodayHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final authAsync = ref.watch(calendarAuthProvider);
    final authorized = authAsync.value?.authorized ?? false;
    final iconSize = AppSpacing.iconSize(context);
    final minTouchSize = AppSpacing.minIconButtonSize(context);

    return SafeArea(
      bottom: false,
      child: Container(
        height: AppSpacing.appBarHeight,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: minTouchSize,
                  height: minTouchSize,
                  child: UserAvatarButton(
                    size: iconSize,
                    onTap: () => handleAvatarNavigation(context),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'CiaraOS',
                  style: AppTypography.headingMediumResponsive(context).copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Icon(
                  Icons.terminal,
                  color: colorScheme.primary,
                  size: iconSize,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                    size: iconSize,
                  ),
                  padding: EdgeInsets.all(AppSpacing.sm),
                  constraints: BoxConstraints(
                    minWidth: minTouchSize,
                    minHeight: minTouchSize,
                  ),
                  tooltip: 'Calendar',
                ),
                IconButton(
                  onPressed: () => context.push('/daily-brief?review=true'),
                  icon: Icon(
                    Icons.rocket_launch,
                    color: colorScheme.onSurfaceVariant,
                    size: iconSize,
                  ),
                  padding: EdgeInsets.all(AppSpacing.sm),
                  constraints: BoxConstraints(
                    minWidth: minTouchSize,
                    minHeight: minTouchSize,
                  ),
                  tooltip: 'Daily Brief',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}