import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/planning_accuracy_data.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:ciaraos/utils/planning_accuracy_utils.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/widgets/analytics/accuracy_trend_chart.dart';
import 'package:ciaraos/widgets/analytics/inline_section_empty_state.dart';
import 'package:ciaraos/widgets/navigation/sidebar_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const kAccuracyMinTasks = 5;

enum _AccuracyDataState { thresholdNotMet, partial, full }

_AccuracyDataState _resolveState(int qualifyingCount) {
  if (qualifyingCount == 0) {
    return _AccuracyDataState.thresholdNotMet;
  }
  if (qualifyingCount < kAccuracyMinTasks) {
    return _AccuracyDataState.partial;
  }
  return _AccuracyDataState.full;
}

int _qualifyingTaskCount(List<Task> tasks) {
  return countQualifyingPlanningAccuracyTasks(tasks);
}

class PlanningAccuracyScreen extends ConsumerWidget {
  const PlanningAccuracyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(allTasksProvider);
    final dataAsync = ref.watch(planningAccuracyProvider);

    return SidebarScreenScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          const _ScreenIntro(),
          const SizedBox(height: AppSpacing.lg),
          tasksAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Text(
              'Could not load planning accuracy.',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            data: (tasks) {
              final qualifyingCount = _qualifyingTaskCount(tasks);
              final state = _resolveState(qualifyingCount);

              return dataAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => Text(
                  'Could not load planning accuracy.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                data: (accuracyData) => _PlanningAccuracyBody(
                  data: accuracyData,
                  qualifyingCount: qualifyingCount,
                  state: state,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ScreenIntro extends StatelessWidget {
  const _ScreenIntro();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ANALYTICS',
          style: AppTypography.labelSmallResponsive(context).copyWith(
            color: colorScheme.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Planning Accuracy',
          style: AppTypography.headingLargeResponsive(context).copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Detailed analysis of estimated duration vs. actual execution reality.',
          style: AppTypography.bodyMediumResponsive(context).copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PlanningAccuracyBody extends StatelessWidget {
  const _PlanningAccuracyBody({
    required this.data,
    required this.qualifyingCount,
    required this.state,
  });

  final PlanningAccuracyData data;
  final int qualifyingCount;
  final _AccuracyDataState state;

  bool get _showFull => state == _AccuracyDataState.full;
  bool get _showPartial => state == _AccuracyDataState.partial;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OverallScoreCard(
          data: data,
          qualifyingCount: qualifyingCount,
          state: state,
        ),
        const SizedBox(height: AppSpacing.lg),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_showFull || _showPartial)
                AccuracyTrendChart(points: data.eightWeekTrend)
              else
                const ChartPlaceholder(
                  overlayLabel: 'Awaiting execution data…',
                ),
              if (_showPartial)
                TrendBuildingNote(
                  message:
                      'Building your trend… $qualifyingCount tasks logged',
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ByDomainCard(
          data: data,
          qualifyingCount: qualifyingCount,
          state: state,
        ),
        const SizedBox(height: AppSpacing.lg),
        _WorstEstimatesCard(
          data: data,
          qualifyingCount: qualifyingCount,
          state: state,
        ),
        if (_showFull && data.tip != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _TipsCard(tip: data.tip!),
        ] else if (!_showFull) ...[
          const SizedBox(height: AppSpacing.lg),
          _CalibrationProgressCard(
            qualifyingCount: qualifyingCount,
            state: state,
          ),
        ],
      ],
    );
  }
}

class _OverallScoreCard extends StatelessWidget {
  const _OverallScoreCard({
    required this.data,
    required this.qualifyingCount,
    required this.state,
  });

  final PlanningAccuracyData data;
  final int qualifyingCount;
  final _AccuracyDataState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state == _AccuracyDataState.thresholdNotMet) {
      return _Card(
        child: InlineSectionEmptyState(
          title: 'No accuracy data yet',
          message:
              'Your overall planning accuracy score will appear here once you complete tasks with time estimates.',
          actionHint:
              'Mark tasks done after deep work sessions with estimates set',
          progressCurrent: qualifyingCount,
          progressMax: kAccuracyMinTasks,
          icon: Icons.track_changes_outlined,
        ),
      );
    }

    final delta = data.deltaVsPriorPeriod;
    final deltaPositive = delta != null && delta >= 0;
    final showDelta = state == _AccuracyDataState.full && delta != null;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OVERALL ACCURACY',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatPlanningAccuracy(data.overallAccuracy),
                style: AppTypography.displayLarge.copyWith(
                  color: colorScheme.primary,
                  fontSize: 56,
                  height: 1,
                ),
              ),
              if (showDelta) ...[
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        deltaPositive
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 14,
                        color: colorScheme.tertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        formatAccuracyDelta(delta),
                        style: AppTypography.labelSmall.copyWith(
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (data.summaryText.isNotEmpty)
            Text(
              data.summaryText,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            )
          else if (state == _AccuracyDataState.partial)
            Text(
              'Early signal from $qualifyingCount completed tasks. '
              'Complete ${kAccuracyMinTasks - qualifyingCount} more to unlock full calibration insights.',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}

class _ByDomainCard extends StatelessWidget {
  const _ByDomainCard({
    required this.data,
    required this.qualifyingCount,
    required this.state,
  });

  final PlanningAccuracyData data;
  final int qualifyingCount;
  final _AccuracyDataState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACCURACY BY DOMAIN',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (state == _AccuracyDataState.thresholdNotMet)
            ...Domain.values.map(
              (domain) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _DomainPlaceholderRow(domain: domain),
              ),
            )
          else if (data.byDomain.isEmpty)
            InlineSectionEmptyState(
              message:
                  'Domain breakdown will appear once completed tasks span multiple domains.',
              actionHint: 'Complete tasks with estimates across domains',
              compact: true,
              icon: Icons.donut_large_outlined,
            )
          else
            ...data.byDomain.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _DomainAccuracyRow(entry: entry),
              ),
            ),
          if (state == _AccuracyDataState.thresholdNotMet) ...[
            const SizedBox(height: AppSpacing.sm),
            InlineSectionEmptyState(
              message:
                  'Per-domain accuracy bars compare estimate vs. actual focused time.',
              actionHint: 'Complete tasks that have time estimates',
              progressCurrent: qualifyingCount,
              progressMax: kAccuracyMinTasks,
              compact: true,
              icon: Icons.bar_chart_outlined,
            ),
          ],
        ],
      ),
    );
  }
}

class _DomainPlaceholderRow extends StatelessWidget {
  const _DomainPlaceholderRow({required this.domain});

  final Domain domain;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = AppColors.domainColors[domain]!;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: domainColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            domainLabel(domain),
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          '0 tasks with estimates',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DomainAccuracyRow extends StatelessWidget {
  const _DomainAccuracyRow({required this.entry});

  final DomainAccuracy entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = AppColors.domainColors[entry.domain]!;
    final overUnder = entry.avgOverUnderMinutes;
    final overUnderLabel = overUnder >= 0
        ? '+${overUnder.round()}m'
        : '${overUnder.round()}m';
    final overUnderColor = overUnder > 0
        ? colorScheme.error
        : overUnder < 0
            ? colorScheme.tertiary
            : colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: domainColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  domainLabel(entry.domain),
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: (entry.accuracyPercent / 100).clamp(0, 1),
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 48,
          child: Text(
            overUnderLabel,
            textAlign: TextAlign.right,
            style: AppTypography.labelSmall.copyWith(color: overUnderColor),
          ),
        ),
      ],
    );
  }
}

class _WorstEstimatesCard extends StatelessWidget {
  const _WorstEstimatesCard({
    required this.data,
    required this.qualifyingCount,
    required this.state,
  });

  final PlanningAccuracyData data;
  final int qualifyingCount;
  final _AccuracyDataState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'TOP 5 MISSES',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (state == _AccuracyDataState.thresholdNotMet)
            InlineSectionEmptyState(
              title: 'No misses tracked yet',
              message:
                  'Your largest estimate gaps will rank here to sharpen future planning.',
              actionHint:
                  'Complete tasks with time estimates after deep work',
              progressCurrent: qualifyingCount,
              progressMax: kAccuracyMinTasks,
              icon: Icons.query_stats_outlined,
              compact: true,
            )
          else if (data.worstEstimates.isEmpty)
            InlineSectionEmptyState(
              message: 'No estimate misses recorded yet.',
              compact: true,
              icon: Icons.query_stats_outlined,
            )
          else
            ...data.worstEstimates.map(
              (miss) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _MissRow(miss: miss),
              ),
            ),
        ],
      ),
    );
  }
}

class _CalibrationProgressCard extends StatelessWidget {
  const _CalibrationProgressCard({
    required this.qualifyingCount,
    required this.state,
  });

  final int qualifyingCount;
  final _AccuracyDataState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lightbulb_outline, color: colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calibration Tip',
                  style: AppTypography.headingMedium.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  state == _AccuracyDataState.thresholdNotMet
                      ? 'Start adding time estimates when creating tasks. After $kAccuracyMinTasks completions, you will see how accurate your planning is.'
                      : 'You are $qualifyingCount of $kAccuracyMinTasks tasks in. Keep completing estimated tasks to unlock full trend and tip insights.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Calibration Progress',
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      '$qualifyingCount / $kAccuracyMinTasks',
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  child: LinearProgressIndicator(
                    value: (qualifyingCount / kAccuracyMinTasks).clamp(0, 1),
                    minHeight: 6,
                    backgroundColor:
                        colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissRow extends StatelessWidget {
  const _MissRow({required this.miss});

  final TaskAccuracyMiss miss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSevere = miss.gapMinutes.abs() >= miss.estimatedMinutes * 0.25;
    final borderColor =
        isSevere ? colorScheme.error : colorScheme.outlineVariant;
    final gapLabel = miss.gapPercent >= 0
        ? '+${miss.gapPercent.round()}%'
        : '${miss.gapPercent.round()}%';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isSevere
            ? colorScheme.errorContainer.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        border: Border(
          left: BorderSide(color: borderColor, width: 2),
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  miss.title,
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Est: ${formatMinutesLabel(miss.estimatedMinutes)} | Act: ${formatMinutesLabel(miss.actualMinutes)}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            gapLabel,
            style: AppTypography.labelSmall.copyWith(
              color: isSevere ? colorScheme.error : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lightbulb_outline, color: colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calibration Insights',
                  style: AppTypography.headingMedium.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  tip,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: child,
    );
  }
}
