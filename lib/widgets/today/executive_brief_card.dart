import 'package:ciaraos/models/executive_brief.dart';
import 'package:ciaraos/providers/ai_providers.dart';
import 'package:ciaraos/providers/opportunity_providers.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/services/ai_context_builder.dart';
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

  @override
  void initState() {
    super.initState();
    _isCollapsed = ref.read(executiveBriefProvider).value != null;
  }

  Future<void> _fetchBrief() async {
    setState(() => _fetchFailed = false);

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
    setState(() {
      _fetchFailed = brief == null;
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

    return _BriefCardShell(
      colorScheme: colorScheme,
      child: isLoading
          ? const _LoadingBriefContent()
          : brief != null
              ? _isCollapsed
                  ? _CollapsedBriefContent(
                      brief: brief,
                      onExpand: () => setState(() => _isCollapsed = false),
                      onRefresh: _fetchBrief,
                    )
                  : _LoadedBriefContent(
                      brief: brief,
                      onRefresh: _fetchBrief,
                      onCollapse: () => setState(() => _isCollapsed = true),
                    )
              : _fetchFailed
                  ? _ErrorBriefContent(onRetry: _fetchBrief)
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: AppSpacing.taskBorderWidth,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(AppSpacing.radiusLg),
                ),
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                  right: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _BriefLabel extends StatelessWidget {
  const _BriefLabel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      'EXECUTIVE BRIEF',
      style: AppTypography.labelLarge.copyWith(
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 1.5,
        decoration: TextDecoration.none,
      ),
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
        const _BriefLabel(),
        const SizedBox(height: AppSpacing.md),
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
            "⚡ Generate Today's Mission",
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onPrimary,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingBriefContent extends StatelessWidget {
  const _LoadingBriefContent();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _BriefLabel(),
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
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _ErrorBriefContent extends StatelessWidget {
  const _ErrorBriefContent({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _BriefLabel(),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Could not reach AI backend. Is the backend running?',
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onRetry,
            child: Text(
              'RETRY',
              style: AppTypography.labelLarge.copyWith(
                color: colorScheme.primary,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CollapsedBriefContent extends StatelessWidget {
  const _CollapsedBriefContent({
    required this.brief,
    required this.onExpand,
    required this.onRefresh,
  });

  final ExecutiveBrief brief;
  final VoidCallback onExpand;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        const _BriefLabel(),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            brief.mission.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurface,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        IconButton(
          onPressed: onRefresh,
          icon: Icon(
            Icons.refresh,
            size: AppSpacing.lg,
            color: colorScheme.onSurfaceVariant,
          ),
          tooltip: 'Refresh brief',
        ),
        IconButton(
          onPressed: onExpand,
          icon: Icon(
            Icons.expand_more,
            size: AppSpacing.lg,
            color: colorScheme.onSurfaceVariant,
          ),
          tooltip: 'Expand brief',
        ),
      ],
    );
  }
}

class _LoadedBriefContent extends StatelessWidget {
  const _LoadedBriefContent({
    required this.brief,
    required this.onRefresh,
    required this.onCollapse,
  });

  final ExecutiveBrief brief;
  final VoidCallback onRefresh;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: _BriefLabel()),
            IconButton(
              onPressed: onRefresh,
              icon: Icon(
                Icons.refresh,
                size: AppSpacing.lg,
                color: colorScheme.onSurfaceVariant,
              ),
              tooltip: 'Refresh brief',
            ),
            IconButton(
              onPressed: onCollapse,
              icon: Icon(
                Icons.expand_less,
                size: AppSpacing.lg,
                color: colorScheme.onSurfaceVariant,
              ),
              tooltip: 'Collapse brief',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          brief.greeting,
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          "TODAY'S MISSION",
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          brief.mission.title,
          style: AppTypography.headingMedium.copyWith(
            color: colorScheme.onSurface,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          brief.mission.reason,
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Est. ${brief.mission.estimatedMinutes} min',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            decoration: TextDecoration.none,
          ),
        ),
        if (brief.risk.present && brief.risk.description != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border(
                left: BorderSide(
                  color: colorScheme.tertiary,
                  width: AppSpacing.taskBorderWidth,
                ),
              ),
            ),
            child: Text(
              '⚠ ${brief.risk.description}',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          'RECOMMENDATION',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          brief.recommendation,
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurface,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Priority Score: ${brief.priorityScore}/100',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.primary,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          brief.expectedOutcome,
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
