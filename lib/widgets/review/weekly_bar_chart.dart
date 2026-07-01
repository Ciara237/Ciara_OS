import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.dailyRates,
    required this.todayIndex,
  });

  final List<double> dailyRates;
  final int todayIndex;

  static const _dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasData = dailyRates.any((rate) => rate > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _BarColumn(
                    rate: dailyRates[i],
                    isToday: i == todayIndex,
                    trackColor: colorScheme.surfaceContainerHighest,
                    fillColor: i == todayIndex
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (var i = 0; i < 7; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _dayLabels[i],
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (!hasData) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No data yet this week',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.rate,
    required this.isToday,
    required this.trackColor,
    required this.fillColor,
  });

  final double rate;
  final bool isToday;
  final Color trackColor;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    final fillHeight = 160 * rate.clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: trackColor.withValues(alpha: isToday ? 0.35 : 0.5),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusSm),
            ),
          ),
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: fillHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isToday ? fillColor : fillColor.withValues(alpha: 0.65),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusSm),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
