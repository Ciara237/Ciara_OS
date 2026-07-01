import 'package:ciaraos/models/weekly_debrief.dart';
import 'package:ciaraos/models/weekly_execution_metrics.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:ciaraos/widgets/review/review_card.dart';
import 'package:flutter/material.dart';

class ExecutionSummaryCard extends StatelessWidget {
  const ExecutionSummaryCard({
    super.key,
    required this.debrief,
  });

  final WeeklyDebrief debrief;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final metrics = debrief.metrics;
    final score = debrief.executionScore.round();
    final delta = debrief.scoreDelta;

    final deltaColor = !debrief.hasPriorWeekData
        ? colorScheme.onSurfaceVariant
        : (delta != null && delta > 0
            ? colorScheme.primary
            : delta != null && delta < 0
                ? colorScheme.error
                : colorScheme.onSurfaceVariant);

    final deltaText = !debrief.hasPriorWeekData
        ? null
        : '${delta! >= 0 ? '+' : ''}${delta.round()}%';

    return ReviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EXECUTIVE SUMMARY',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 640;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _scoreBlock(
                        score,
                        deltaText,
                        deltaColor,
                        colorScheme,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      flex: 2,
                      child: _metricsGrid(metrics, colorScheme),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _scoreBlock(score, deltaText, deltaColor, colorScheme),
                  const SizedBox(height: AppSpacing.xl),
                  _metricsGrid(metrics, colorScheme),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _scoreBlock(
    int score,
    String? deltaText,
    Color deltaColor,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Execution Score: $score%',
          style: AppTypography.displayLarge.copyWith(
            color: colorScheme.onSurface,
            fontSize: 36,
            height: 1.1,
          ),
        ),
        if (deltaText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                deltaText.startsWith('+')
                    ? Icons.trending_up
                    : deltaText.startsWith('-')
                        ? Icons.trending_down
                        : Icons.trending_flat,
                size: AppSpacing.md,
                color: deltaColor,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                deltaText,
                style: AppTypography.bodyMedium.copyWith(color: deltaColor),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _metricsGrid(WeeklyExecutionMetrics metrics, ColorScheme colorScheme) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.lg,
      crossAxisSpacing: AppSpacing.lg,
      childAspectRatio: 2.2,
      children: [
        _metricCell(
          'Tasks Completed',
          '${metrics.tasksCompleted}',
          colorScheme,
        ),
        _metricCell(
          'Deep Work',
          formatFocusUptime(metrics.deepWorkSeconds),
          colorScheme,
        ),
        _metricCell(
          'Focus Sessions',
          '${metrics.focusSessionCount}',
          colorScheme,
        ),
        _metricCell(
          'Planning Accuracy',
          formatPlanningAccuracy(metrics.planningAccuracy),
          colorScheme,
        ),
        _metricCell(
          'Longest Streak',
          '${metrics.longestStreak}d',
          colorScheme,
        ),
        _metricCell(
          'Biggest Win',
          metrics.biggestWin ?? '—',
          colorScheme,
          emphasize: true,
        ),
      ],
    );
  }

  Widget _metricCell(
    String label,
    String value,
    ColorScheme colorScheme, {
    bool emphasize = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: (emphasize
                  ? AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)
                  : AppTypography.headingMedium)
              .copyWith(
            color: emphasize ? colorScheme.primary : colorScheme.onSurface,
            fontSize: emphasize ? 16 : 24,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
