import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/review_stats_utils.dart';
import 'package:flutter/material.dart';

const _reviewHeaderWideBreakpoint = 768.0;

class ReviewScreenHeader extends StatelessWidget {
  const ReviewScreenHeader({
    super.key,
    required this.weekMonday,
    required this.onExport,
    required this.onFinalize,
  });

  final DateTime weekMonday;
  final VoidCallback onExport;
  final VoidCallback onFinalize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide =
        MediaQuery.sizeOf(context).width >= _reviewHeaderWideBreakpoint;

    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXECUTIVE DEBRIEF',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.primary,
            letterSpacing: 2,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          reviewWeekHeaderLabel(weekMonday),
          style: (isWide ? AppTypography.headingLarge : AppTypography.headingMedium)
              .copyWith(
            color: colorScheme.onSurface,
            fontSize: isWide ? 26 : 22,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Strategic performance analysis and system recalibration.',
          style: AppTypography.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 17,
            height: 1.45,
          ),
        ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: onExport,
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
            side: BorderSide(color: colorScheme.outlineVariant),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          child: Text(
            'Export Report',
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        FilledButton(
          onPressed: onFinalize,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          child: Text(
            'Finalize Review',
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: titleSection),
          actions,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleSection,
        const SizedBox(height: AppSpacing.md),
        actions,
      ],
    );
  }
}
