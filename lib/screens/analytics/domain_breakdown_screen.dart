import 'package:ciaraos/models/domain_analytics.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/widgets/navigation/sidebar_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _periodOptions = <({String value, String label})>[
  (value: 'week', label: 'This week'),
  (value: 'month', label: 'This month'),
  (value: 'all', label: 'All'),
];

class DomainBreakdownScreen extends ConsumerWidget {
  const DomainBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(domainBreakdownPeriodProvider);
    final breakdownAsync = ref.watch(domainBreakdownProvider(period));

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
          _PeriodChips(
            selected: period,
            onSelected: (value) =>
                ref.read(domainBreakdownPeriodProvider.notifier).state = value,
          ),
          const SizedBox(height: AppSpacing.lg),
          breakdownAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Text(
              'Could not load domain breakdown.',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            data: (data) => _BreakdownBody(data: data),
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
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Domain Breakdown',
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Time and tasks distribution across active spheres.',
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PeriodChips extends StatelessWidget {
  const _PeriodChips({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _periodOptions.map((option) {
        final isSelected = selected == option.value;
        return FilterChip(
          label: Text(option.label),
          selected: isSelected,
          onSelected: (_) => onSelected(option.value),
          showCheckmark: false,
          labelStyle: AppTypography.labelSmall.copyWith(
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
          backgroundColor: colorScheme.surfaceContainer,
          selectedColor: colorScheme.primaryContainer,
          side: BorderSide(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.2)
                : colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
          shape: const StadiumBorder(),
        );
      }).toList(),
    );
  }
}

class _BreakdownBody extends StatelessWidget {
  const _BreakdownBody({required this.data});

  final DomainBreakdownData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DistributionCard(data: data),
        if (data.imbalanceAlerts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _ImbalanceAlert(alerts: data.imbalanceAlerts),
        ],
        const SizedBox(height: AppSpacing.lg),
        ...data.domainStats.map(
          (stats) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _DomainDetailCard(stats: stats),
          ),
        ),
      ],
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({required this.data});

  final DomainBreakdownData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final segments = data.domainStats
        .where((stat) => stat.sharePercent > 0)
        .toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AGGREGATE WORKLOAD',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Total: ${data.totalTasks} tasks',
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (segments.isEmpty)
            Container(
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              alignment: Alignment.center,
              child: Text(
                'No tasks in this period',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: SizedBox(
                height: 32,
                child: Row(
                  children: segments.map((stat) {
                    return Expanded(
                      flex: stat.totalTasks,
                      child: Container(
                        color: AppColors.domainColors[stat.domain],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.md,
              children: segments.map((stat) {
                final color = AppColors.domainColors[stat.domain]!;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          domainLabel(stat.domain),
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${stat.sharePercent.round()}% · ${stat.totalTasks} tasks',
                          style: AppTypography.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ImbalanceAlert extends StatelessWidget {
  const _ImbalanceAlert({required this.alerts});

  final List<DomainImbalanceAlert> alerts;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = alerts.first;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: colorScheme.tertiary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IMBALANCE DETECTED',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  alerts.length == 1
                      ? primary.message
                      : '${alerts.length} domains have no tasks this period, including ${domainLabel(primary.domain)}.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
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

class _DomainDetailCard extends StatelessWidget {
  const _DomainDetailCard({required this.stats});

  final DomainStats stats;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = AppColors.domainColors[stats.domain]!;
    final focusHours = stats.totalFocusedSeconds / 3600;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(color: domainColor, child: const SizedBox(width: 3)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          domainIcon(stats.domain),
                          color: domainColor,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          domainLabel(stats.domain),
                          style: AppTypography.labelLarge.copyWith(
                            color: domainColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${stats.totalTasks} tasks',
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          focusHours.toStringAsFixed(1),
                          style: AppTypography.displayLarge.copyWith(
                            color: colorScheme.onSurface,
                            fontSize: 32,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Focus hours',
                            style: AppTypography.labelSmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _StatRow(
                      label: 'Completed',
                      value: '${stats.completedTasks}',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                      child: LinearProgressIndicator(
                        value: stats.completionRate.clamp(0, 1),
                        minHeight: 4,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: domainColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _StatRow(
                      label: 'In progress',
                      value: '${stats.inProgressTasks}',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _StatRow(
                      label: 'Stuck',
                      value: '${stats.stuckTasks}',
                      valueColor:
                          stats.stuckTasks > 0 ? const Color(0xFFF87171) : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'STARTED RATE',
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '${(stats.startedRate * 100).round()}%',
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.primary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      stats.mostPostponedTaskTitle == null
                          ? 'Most postponed: None'
                          : 'Most postponed: "${stats.mostPostponedTaskTitle}" (${stats.mostPostponedCount}×)',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelSmall.copyWith(
            color: valueColor ?? colorScheme.onSurface,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
