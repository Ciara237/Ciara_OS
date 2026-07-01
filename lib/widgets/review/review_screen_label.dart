import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Positive delta green — matches Opportunities active status dot.
const reviewPositiveDeltaColor = Color(0xFF10B981);

class ReviewScreenLabel extends StatelessWidget {
  const ReviewScreenLabel({
    super.key,
    required this.focusScorePercent,
    required this.deltaPercent,
    required this.hasPriorWeekData,
    required this.insightText,
  });

  final int focusScorePercent;
  final double? deltaPercent;
  final bool hasPriorWeekData;
  final String insightText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final deltaColor = !hasPriorWeekData
        ? colorScheme.onSurfaceVariant
        : (deltaPercent! > 0
            ? reviewPositiveDeltaColor
            : deltaPercent! < 0
                ? colorScheme.error
                : colorScheme.onSurfaceVariant);

    final deltaText = !hasPriorWeekData
        ? '—'
        : '${deltaPercent! >= 0 ? '+' : ''}${deltaPercent!.toStringAsFixed(1)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WEEKLY PERFORMANCE',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$focusScorePercent%',
              style: AppTypography.displayLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              deltaText,
              style: AppTypography.bodyLarge.copyWith(color: deltaColor),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Focus Score',
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          insightText,
          style: AppTypography.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
