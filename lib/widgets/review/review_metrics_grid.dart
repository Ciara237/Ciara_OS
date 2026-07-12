import 'package:ciaraos/models/weekly_execution_metrics.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:flutter/material.dart';

const _accuracyAccent = Color(0xFFF97316);

class ReviewMetricsGrid extends StatelessWidget {
  const ReviewMetricsGrid({
    super.key,
    required this.metrics,
  });

  final WeeklyExecutionMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final startedRate = (metrics.startedRate * 100).round();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.95,
      children: [
        _MetricTile(
          label: 'COMPLETION RATE',
          value: '${(metrics.taskCompletionRate * 100).round()}%',
          trailing: Icon(
            Icons.check_circle_outline,
            size: 16,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        _MetricTile(
          label: 'STARTED RATE',
          value: '$startedRate%',
          trailing: Icon(
            Icons.show_chart,
            size: 16,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        _MetricTile(
          label: 'TASKS DONE',
          value: '${metrics.tasksCompleted} / ${metrics.tasksInScope}',
        ),
        _MetricTile(
          label: 'FOCUS HRS',
          value: formatFocusUptime(metrics.deepWorkSeconds),
          trailing: Icon(
            Icons.bolt_outlined,
            size: 16,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        _MetricTile(
          label: 'ACCURACY',
          value: formatPlanningAccuracy(metrics.planningAccuracy),
          trailing: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: _accuracyAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardPadding = AppSpacing.cardPadding(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: cardPadding,
        vertical: cardPadding - 4,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmallResponsive(context).copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.statMediumResponsive(context).copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
