import 'package:ciaraos/models/completed_tasks_data.dart';
import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/providers/completed_tasks_providers.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/widgets/completed_tasks/completed_task_card.dart';
import 'package:ciaraos/widgets/completed_tasks/weekly_distribution_chart.dart';
import 'package:ciaraos/widgets/common/execution_archive_export_sheet.dart';
import 'package:ciaraos/widgets/navigation/minimal_back_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompletedTasksScreen extends ConsumerWidget {
  const CompletedTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final dataAsync = ref.watch(completedTasksProvider);
    final projectsAsync = ref.watch(allProjectsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MinimalBackHeader(
            action: IconButton(
              tooltip: 'Export',
              onPressed: () => showExecutionArchiveExportSheet(context, ref),
              icon: Icon(
                Icons.download,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: dataAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'Could not load completed tasks.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              data: (data) {
                final projectNames = {
                  for (final project in projectsAsync.value ?? [])
                    project.id: project.name,
                };

                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const _ScreenIntro(),
                    const SizedBox(height: AppSpacing.lg),
                    _StatsGrid(stats: data.stats),
                    const SizedBox(height: AppSpacing.lg),
                    _FilterBar(data: data),
                    const SizedBox(height: AppSpacing.lg),
                    _VisualizationCard(points: data.weeklyDistribution),
                    const SizedBox(height: AppSpacing.xl),
                    if (data.sections.isEmpty)
                      _EmptyFilteredState(data: data)
                    else
                      ...data.sections.expand(
                        (section) => [
                          _SectionHeader(section: section),
                          const SizedBox(height: AppSpacing.sm),
                          ...section.tasks.map(
                            (task) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: CompletedTaskCard(
                                task: task,
                                projectName: task.projectId == null
                                    ? null
                                    : projectNames[task.projectId],
                                onTap: () => context.push('/tasks/${task.id}'),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    if (data.hasArchive) _ArchiveSection(data: data),
                  ],
                );
              },
            ),
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
          'EXECUTION ARCHIVE',
          style: AppTypography.labelSmallResponsive(context).copyWith(
            color: colorScheme.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Completed Tasks',
          style: AppTypography.headingLargeResponsive(context).copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 2,
              height: 36,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Every completed task represents progress.',
                style: AppTypography.bodyMediumResponsive(context).copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final CompletedTasksStats stats;

  @override
  Widget build(BuildContext context) {
    final change = stats.weekOverWeekChangePercent;
    final changeLabel = change == null
        ? '— vs last week'
        : '${change >= 0 ? '+' : ''}${change.round()}% vs last week';

    final cards = [
      _StatCard(
        label: 'Total Completed',
        value: _formatCount(stats.totalCompleted),
        footer: LinearProgressIndicator(
          value: (stats.weeklySharePercent / 100).clamp(0.05, 1.0),
          minHeight: 2,
          backgroundColor:
              Theme.of(context).colorScheme.outlineVariant.withValues(
                    alpha: 0.25,
                  ),
        ),
      ),
      _StatCard(
        label: 'This Week',
        value: '${stats.completedThisWeek}',
        subtitle: changeLabel,
        subtitleColor: change != null && change >= 0
            ? const Color(0xFF10B981)
            : Theme.of(context).colorScheme.error,
      ),
      _StatCard(
        label: 'Deep Work Hours',
        value: '${stats.deepWorkHoursThisWeek.toStringAsFixed(1)}h',
        subtitle:
            'Avg ${stats.avgDeepWorkHoursPerDay.toStringAsFixed(1)}h/day',
      ),
      _StatCard(
        label: 'Avg Accuracy',
        value: stats.avgAccuracy == null
            ? '—'
            : '${stats.avgAccuracy!.toStringAsFixed(1)}%',
        ratingDots: stats.avgAccuracy,
      ),
    ];

    return Column(
      children: [
        for (var row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: AppSpacing.sm),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: cards[row * 2]),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: cards[row * 2 + 1]),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatCount(int value) {
    return NumberFormat.decimalPattern().format(value);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.subtitle,
    this.subtitleColor,
    this.footer,
    this.ratingDots,
  });

  final String label;
  final String value;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? footer;
  final double? ratingDots;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: subtitleColor ?? colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (ratingDots != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _AccuracyDots(score: ratingDots!),
          ],
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.sm),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _AccuracyDots extends StatelessWidget {
  const _AccuracyDots({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filled = (score / 20).ceil().clamp(0, 5);

    return Row(
      children: List.generate(5, (index) {
        return Container(
          width: 6,
          height: 6,
          margin: EdgeInsets.only(right: index == 4 ? 0 : 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < filled
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        );
      }),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.data});

  final CompletedTasksData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(completedTasksFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: CompletedTasksFilter.values.map((chip) {
              final selected = filter == chip;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: FilterChip(
                  label: Text(_filterLabel(chip)),
                  selected: selected,
                  onSelected: (_) {
                    ref.read(completedTasksFilterProvider.notifier).state =
                        chip;
                    if (chip != CompletedTasksFilter.domain) {
                      ref
                          .read(completedTasksDomainFilterProvider.notifier)
                          .state = null;
                    }
                    if (chip != CompletedTasksFilter.priority) {
                      ref
                          .read(completedTasksPriorityFilterProvider.notifier)
                          .state = null;
                    }
                    if (chip != CompletedTasksFilter.project) {
                      ref
                          .read(completedTasksProjectFilterProvider.notifier)
                          .state = null;
                    }
                  },
                  labelStyle: AppTypography.labelSmall.copyWith(
                    color: selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  selectedColor: colorScheme.primaryContainer,
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  side: BorderSide(
                    color: selected
                        ? colorScheme.primary.withValues(alpha: 0.4)
                        : colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                ),
              );
            }).toList(),
          ),
        ),
        if (filter == CompletedTasksFilter.domain &&
            data.availableDomains.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _SecondaryFilterRow<Domain>(
            items: data.availableDomains,
            selected: ref.watch(completedTasksDomainFilterProvider),
            labelBuilder: domainLabel,
            onSelected: (value) => ref
                .read(completedTasksDomainFilterProvider.notifier)
                .state = value,
          ),
        ],
        if (filter == CompletedTasksFilter.priority &&
            data.availablePriorities.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _SecondaryFilterRow<Priority>(
            items: data.availablePriorities,
            selected: ref.watch(completedTasksPriorityFilterProvider),
            labelBuilder: (priority) => priority.name.toUpperCase(),
            onSelected: (value) => ref
                .read(completedTasksPriorityFilterProvider.notifier)
                .state = value,
          ),
        ],
        if (filter == CompletedTasksFilter.project &&
            data.availableProjects.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _ProjectFilterRow(
            projects: data.availableProjects,
            selectedProjectId: ref.watch(completedTasksProjectFilterProvider),
            onSelected: (id) => ref
                .read(completedTasksProjectFilterProvider.notifier)
                .state = id,
          ),
        ],
      ],
    );
  }

  String _filterLabel(CompletedTasksFilter filter) {
    return switch (filter) {
      CompletedTasksFilter.all => 'All',
      CompletedTasksFilter.today => 'Today',
      CompletedTasksFilter.project => 'Project',
      CompletedTasksFilter.domain => 'Domain',
      CompletedTasksFilter.priority => 'Priority',
    };
  }
}

class _SecondaryFilterRow<T> extends StatelessWidget {
  const _SecondaryFilterRow({
    required this.items,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  final List<T> items;
  final T? selected;
  final String Function(T item) labelBuilder;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(labelBuilder(item)),
                selected: selected == item,
                onSelected: (_) => onSelected(selected == item ? null : item),
                labelStyle: AppTypography.labelSmall.copyWith(
                  color: selected == item
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                selectedColor: colorScheme.secondaryContainer,
                backgroundColor: colorScheme.surfaceContainer,
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProjectFilterRow extends StatelessWidget {
  const _ProjectFilterRow({
    required this.projects,
    required this.selectedProjectId,
    required this.onSelected,
  });

  final List<CompletedProjectOption> projects;
  final int? selectedProjectId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final project in projects)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(project.name),
                selected: selectedProjectId == project.id,
                onSelected: (_) => onSelected(
                  selectedProjectId == project.id ? null : project.id,
                ),
                labelStyle: AppTypography.labelSmall.copyWith(
                  color: selectedProjectId == project.id
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                selectedColor: colorScheme.secondaryContainer,
                backgroundColor: colorScheme.surfaceContainer,
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VisualizationCard extends StatelessWidget {
  const _VisualizationCard({required this.points});

  final List<WeeklyDistributionPoint> points;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: WeeklyDistributionChart(points: points),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section});

  final CompletedTaskSection section;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          section.label.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${section.count}',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _EmptyFilteredState extends ConsumerWidget {
  const _EmptyFilteredState({required this.data});

  final CompletedTasksData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Text(
            data.stats.totalCompleted == 0
                ? 'No completed tasks yet.'
                : 'No tasks match the current filters.',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (data.stats.totalCompleted > 0) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () => resetCompletedTasksFilters(ref),
              child: const Text('CLEAR FILTERS'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArchiveSection extends ConsumerWidget {
  const _ArchiveSection({required this.data});

  final CompletedTasksData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final archiveLimit = ref.watch(completedTasksArchiveLimitProvider);
    final remaining =
        (data.archiveTaskCount - archiveLimit).clamp(0, data.archiveTaskCount);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            archiveLimit == 0
                ? 'Load more from historical archive'
                : remaining > 0
                    ? '$remaining older tasks remain in archive'
                    : 'Historical archive fully loaded',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: remaining > 0 || archiveLimit == 0
                ? () => loadMoreCompletedArchive(ref)
                : null,
            child: Text(
              archiveLimit == 0 ? 'LOAD ARCHIVE' : 'ACCESS DATABASE',
            ),
          ),
        ],
      ),
    );
  }
}
