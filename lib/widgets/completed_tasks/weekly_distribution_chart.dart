import 'package:ciaraos/models/completed_tasks_data.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class WeeklyDistributionChart extends StatelessWidget {
  const WeeklyDistributionChart({
    super.key,
    required this.points,
  });

  final List<WeeklyDistributionPoint> points;

  static const _chartHeight = 128.0;
  static const _labelHeight = 14.0;
  static const _countHeight = 12.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxCount = points.fold<int>(
      0,
      (max, point) => point.count > max ? point.count : max,
    );
    final scaleMax = maxCount == 0 ? 1 : maxCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'VISUALIZATION ALPHA',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'WEEKLY DISTRIBUTION TREND',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: _chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < points.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _BarColumn(
                    point: points[i],
                    scaleMax: scaleMax,
                    barColor: colorScheme.primary,
                    mutedColor: colorScheme.outlineVariant,
                    chartHeight: _chartHeight,
                    labelHeight: _labelHeight,
                    countHeight: _countHeight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.point,
    required this.scaleMax,
    required this.barColor,
    required this.mutedColor,
    required this.chartHeight,
    required this.labelHeight,
    required this.countHeight,
  });

  final WeeklyDistributionPoint point;
  final int scaleMax;
  final Color barColor;
  final Color mutedColor;
  final double chartHeight;
  final double labelHeight;
  final double countHeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ratio = point.count / scaleMax;
    final spacing = AppSpacing.xs * 2;
    final barAreaMax =
        chartHeight - labelHeight - countHeight - spacing;
    final barHeight = (barAreaMax * ratio).clamp(4.0, barAreaMax);

    return SizedBox(
      height: chartHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: countHeight,
            child: Center(
              child: point.count > 0
                  ? Text(
                      '${point.count}',
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 9,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: barHeight,
            decoration: BoxDecoration(
              color: point.count > 0
                  ? barColor.withValues(alpha: 0.85)
                  : mutedColor.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: labelHeight,
            child: Center(
              child: Text(
                point.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
