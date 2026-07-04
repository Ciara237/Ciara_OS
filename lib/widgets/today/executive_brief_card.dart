import 'package:ciaraos/models/executive_brief.dart';
import 'package:ciaraos/providers/ai_providers.dart';
import 'package:ciaraos/providers/calendar_providers.dart';
import 'package:ciaraos/providers/opportunity_providers.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/services/ai_context_builder.dart';
import 'package:ciaraos/services/executive_brief_context_service.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/review_stats_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExecutiveBriefCard extends ConsumerStatefulWidget {
  const ExecutiveBriefCard({super.key});

  @override
  ConsumerState<ExecutiveBriefCard> createState() =>
      _ExecutiveBriefCardState();
}

class _ExecutiveBriefCardState extends ConsumerState<ExecutiveBriefCard> {
  late bool _isCollapsed;
  bool _fetchFailed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isCollapsed = ref.read(executiveBriefProvider).value != null;
  }

  ExecutiveBriefDayContext _dayContext() {
    final allTasks = ref.watch(allTasksProvider).value ?? const [];
    final events = ref.watch(calendarEventsProvider).value ?? const [];
    return ExecutiveBriefContextService().build(
      allTasks: allTasks,
      calendarEvents: events,
    );
  }

  Future<void> _fetchBrief() async {
    setState(() {
      _fetchFailed = false;
      _errorMessage = null;
    });

    final todayTasks = ref.read(todayTasksProvider).value ?? [];
    final monday = mondayOfWeek(DateTime.now());
    final weekTasks = await ref.read(weekTasksProvider(monday).future);
    final projects = ref.read(allProjectsProvider).value ?? [];
    final opportunities = ref.read(allOpportunitiesProvider).value ?? [];
    final allTasks = ref.read(allTasksProvider).value ?? [];

    final payload = AiContextBuilder().build(
      todayTasks: todayTasks,
      weekTasks: weekTasks,
      projects: projects,
      opportunities: opportunities,
      allTasks: allTasks,
    );

    await ref.read(executiveBriefProvider.notifier).fetchBrief(payload);

    if (!mounted) {
      return;
    }

    final brief = ref.read(executiveBriefProvider).value;
    final error = ref.read(executiveBriefProvider.notifier).lastError;
    setState(() {
      _fetchFailed = brief == null;
      _errorMessage = error;
      if (brief != null) {
        _isCollapsed = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final briefAsync = ref.watch(executiveBriefProvider);
    final isLoading = briefAsync.isLoading;
    final brief = briefAsync.value;
    final dayContext = _dayContext();

    return _BriefCardShell(
      colorScheme: colorScheme,
      child: isLoading
          ? _LoadingBriefContent(dayContext: dayContext)
          : brief != null
              ? _isCollapsed
                  ? _CollapsedBriefContent(
                      brief: brief,
                      dayContext: dayContext,
                      onExpand: () => setState(() => _isCollapsed = false),
                      onRefresh: _fetchBrief,
                    )
                  : _LoadedBriefContent(
                      brief: brief,
                      dayContext: dayContext,
                      onRefresh: _fetchBrief,
                      onCollapse: () => setState(() => _isCollapsed = true),
                    )
              : _fetchFailed
                  ? _ErrorBriefContent(
                      message: _errorMessage ??
                          'Could not generate your brief. Try again.',
                      onRetry: _fetchBrief,
                    )
                  : _EmptyBriefContent(onGenerate: _fetchBrief),
    );
  }
}

class _BriefCardShell extends StatelessWidget {
  const _BriefCardShell({
    required this.colorScheme,
    required this.child,
  });

  final ColorScheme colorScheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.16),
        ),
      ),
      child: child,
    );
  }
}

class _BriefHeader extends StatelessWidget {
  const _BriefHeader({
    required this.onRefresh,
    this.onCollapse,
    this.onExpand,
  });

  final VoidCallback onRefresh;
  final VoidCallback? onCollapse;
  final VoidCallback? onExpand;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EXECUTIVE BRIEFING',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.4,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "Today's Mission",
                style: AppTypography.headingLarge.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onRefresh,
          icon: Icon(
            Icons.refresh,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          tooltip: 'Refresh brief',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        if (onCollapse != null)
          IconButton(
            onPressed: onCollapse,
            icon: Icon(
              Icons.open_in_full,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Collapse brief',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        if (onExpand != null)
          IconButton(
            onPressed: onExpand,
            icon: Icon(
              Icons.open_in_full,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Expand brief',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.dayContext});

  final ExecutiveBriefDayContext dayContext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Progress',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
            Text(
              '${dayContext.completedCount} / ${dayContext.totalCount} TASKS',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.8,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: LinearProgressIndicator(
            value: dayContext.progress,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = AppTypography.bodyMedium.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.5,
    );
    final bold = base.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w700,
    );

    return Text.rich(
      TextSpan(children: _richSpansFromMarkup(message, base, bold)),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  const _RecommendationSection({required this.brief});

  final ExecutiveBrief brief;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = AppTypography.bodyMedium.copyWith(
      color: colorScheme.onSurface,
      height: 1.45,
    );
    final bold = base.copyWith(fontWeight: FontWeight.w700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.terminal,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'RECOMMENDATION',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
                fontSize: 10,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'PRIORITY SCORE: ${brief.priorityScore}',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 9,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: _recommendationSpans(
                      recommendation: brief.recommendation,
                      missionTitle: brief.mission.title,
                      baseStyle: base,
                      boldStyle: bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyBriefContent extends StatelessWidget {
  const _EmptyBriefContent({required this.onGenerate});

  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'EXECUTIVE BRIEFING',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.4,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "Today's Mission",
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: onGenerate,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          child: Text(
            "Generate Today's Mission",
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingBriefContent extends StatelessWidget {
  const _LoadingBriefContent({required this.dayContext});

  final ExecutiveBriefDayContext dayContext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'EXECUTIVE BRIEFING',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.4,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "Today's Mission",
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ProgressSection(dayContext: dayContext),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: SizedBox(
            width: AppSpacing.lg,
            height: AppSpacing.lg,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Analyzing your execution context...',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _ErrorBriefContent extends StatelessWidget {
  const _ErrorBriefContent({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'EXECUTIVE BRIEFING',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.4,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          message,
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onRetry,
            child: const Text('RETRY'),
          ),
        ),
      ],
    );
  }
}

class _CollapsedBriefContent extends StatelessWidget {
  const _CollapsedBriefContent({
    required this.brief,
    required this.dayContext,
    required this.onExpand,
    required this.onRefresh,
  });

  final ExecutiveBrief brief;
  final ExecutiveBriefDayContext dayContext;
  final VoidCallback onExpand;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BriefHeader(onRefresh: onRefresh, onExpand: onExpand),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                brief.mission.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              '${dayContext.completedCount}/${dayContext.totalCount}',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoadedBriefContent extends StatelessWidget {
  const _LoadedBriefContent({
    required this.brief,
    required this.dayContext,
    required this.onRefresh,
    required this.onCollapse,
  });

  final ExecutiveBrief brief;
  final ExecutiveBriefDayContext dayContext;
  final VoidCallback onRefresh;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BriefHeader(onRefresh: onRefresh, onCollapse: onCollapse),
        const SizedBox(height: AppSpacing.lg),
        _ProgressSection(dayContext: dayContext),
        const SizedBox(height: AppSpacing.lg),
        _StatusMessage(message: dayContext.statusMessage),
        if (brief.risk.present && brief.risk.description != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            brief.risk.description!,
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.tertiary,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _RecommendationSection(brief: brief),
        if (brief.expectedOutcome.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            brief.expectedOutcome,
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

List<TextSpan> _richSpansFromMarkup(
  String text,
  TextStyle baseStyle,
  TextStyle boldStyle,
) {
  final spans = <TextSpan>[];
  final parts = text.split('**');

  for (var i = 0; i < parts.length; i++) {
    if (parts[i].isEmpty) {
      continue;
    }
    spans.add(
      TextSpan(
        text: parts[i],
        style: i.isOdd ? boldStyle : baseStyle,
      ),
    );
  }

  if (spans.isEmpty) {
    spans.add(TextSpan(text: text, style: baseStyle));
  }

  return spans;
}

List<TextSpan> _recommendationSpans({
  required String recommendation,
  required String missionTitle,
  required TextStyle baseStyle,
  required TextStyle boldStyle,
}) {
  if (missionTitle.isNotEmpty && recommendation.contains(missionTitle)) {
    final parts = recommendation.split(missionTitle);
    final spans = <TextSpan>[];

    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i], style: baseStyle));
      }
      if (i < parts.length - 1) {
        spans.add(TextSpan(text: missionTitle, style: boldStyle));
      }
    }

    return spans;
  }

  return [TextSpan(text: recommendation, style: baseStyle)];
}
