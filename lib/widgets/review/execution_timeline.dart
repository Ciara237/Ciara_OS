import 'package:ciaraos/models/enums/execution_day_quality.dart';
import 'package:ciaraos/models/execution_timeline_day.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/review/review_card.dart';
import 'package:flutter/material.dart';

class ExecutionTimeline extends StatelessWidget {
  const ExecutionTimeline({
    super.key,
    required this.days,
  });

  final List<ExecutionTimelineDay> days;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ReviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'EXECUTION TIMELINE',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 48,
            child: Row(
              children: [
                for (var i = 0; i < days.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _DayBar(
                      day: days[i],
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              _legendItem('Strong', _colorFor(ExecutionDayQuality.strong, colorScheme), colorScheme),
              _legendItem('Moderate', _colorFor(ExecutionDayQuality.moderate, colorScheme), colorScheme),
              _legendItem('Weak', _colorFor(ExecutionDayQuality.weak, colorScheme), colorScheme),
              _legendItem('Review', _colorFor(ExecutionDayQuality.review, colorScheme), colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  static Color _colorFor(ExecutionDayQuality quality, ColorScheme colorScheme) {
    return switch (quality) {
      ExecutionDayQuality.strong => colorScheme.primary,
      ExecutionDayQuality.moderate => colorScheme.tertiary,
      ExecutionDayQuality.weak => colorScheme.error,
      ExecutionDayQuality.review => colorScheme.surfaceContainerHighest,
    };
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.day,
    required this.colorScheme,
  });

  final ExecutionTimelineDay day;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final fill = ExecutionTimeline._colorFor(day.quality, colorScheme);
    final onFill = day.quality == ExecutionDayQuality.review
        ? colorScheme.onSurfaceVariant
        : day.quality == ExecutionDayQuality.moderate
            ? colorScheme.onTertiary
            : day.quality == ExecutionDayQuality.weak
                ? colorScheme.onError
                : colorScheme.onPrimary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Center(
        child: Text(
          day.label,
          style: AppTypography.labelSmall.copyWith(
            color: onFill,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
