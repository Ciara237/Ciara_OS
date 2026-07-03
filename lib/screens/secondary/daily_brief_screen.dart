import 'dart:async';

import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/daily_brief_gate_provider.dart';
import 'package:ciaraos/providers/focus_session_provider.dart';
import 'package:ciaraos/providers/focus_session_repository_provider.dart';
import 'package:ciaraos/providers/profile_providers.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/providers/weekly_debrief_providers.dart';
import 'package:ciaraos/services/daily_brief_metrics.dart';
import 'package:ciaraos/services/daily_brief_state_service.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:ciaraos/utils/focus_duration_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DailyBriefScreen extends ConsumerStatefulWidget {
  const DailyBriefScreen({super.key});

  @override
  ConsumerState<DailyBriefScreen> createState() => _DailyBriefScreenState();
}

class _DailyBriefScreenState extends ConsumerState<DailyBriefScreen> {
  DailyBriefState? _briefState;
  bool _isNavigating = false;
  bool _isResolving = true;
  Timer? _clockTimer;
  String _clockLabel = _formatClock(DateTime.now());

  YesterdaySummary? _yesterday;
  AbsenceStatus? _absenceStatus;
  Task? _topTask;
  Project? _activeProject;
  Task? _interruptedTask;
  int _interruptedElapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() => _clockLabel = _formatClock(DateTime.now()));
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveBriefState());
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  static String _formatClock(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  Future<void> _resolveBriefState() async {
    final todayTasks = ref.read(todayTasksProvider).value ?? const <Task>[];
    final allTasks = ref.read(allTasksProvider).value ?? const <Task>[];
    final projects = ref.read(allProjectsProvider).value ?? const <Project>[];
    final weekReview = await ref.read(currentWeekReviewProvider.future);

    final activeSession =
        await ref.read(focusSessionRepositoryProvider).getActiveSession();
    final hasInterruptedSession = activeSession != null;

    final lastOpenedAt = ref.read(dailyBriefGateProvider).readLastOpenedAt();

    final briefState = DailyBriefStateService().compute(
      todayTasks: todayTasks,
      hasInterruptedSession: hasInterruptedSession,
      lastOpenedAt: lastOpenedAt,
    );

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final sessions = await ref
        .read(focusSessionRepositoryProvider)
        .getCompletedSessionsForDay(yesterday);

    Task? interruptedTask;
    if (activeSession != null) {
      interruptedTask =
          await ref.read(taskRepositoryProvider).getById(activeSession.taskId);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _briefState = briefState;
      _isResolving = false;
      _yesterday = computeYesterdaySummary(
        allTasks: allTasks,
        sessions: sessions,
      );
      _absenceStatus = computeAbsenceStatus(
        allTasks: allTasks,
        projects: projects,
        weekReview: weekReview,
      );
      _topTask = topPriorityTask(todayTasks);
      _activeProject = topActiveProject(projects);
      _interruptedTask = interruptedTask;
      _interruptedElapsedSeconds = activeSession?.liveElapsedSeconds ?? 0;
    });
  }

  String _greetingName() {
    final profile = ref.read(profileProvider);
    final name = profile.resolvedDisplayName;
    if (name == 'Your Name') {
      return 'Ciara';
    }
    return name.split(' ').first;
  }

  String _timeAwareGreeting() {
    final hour = DateTime.now().hour;
    final name = _greetingName();

    if (hour >= 5 && hour < 12) {
      return 'Good morning, $name.';
    }
    if (hour >= 12 && hour < 17) {
      return 'Good afternoon, $name.';
    }
    if (hour >= 17 && hour < 21) {
      return 'Good evening, $name.';
    }
    return 'Working late, $name.';
  }

  String _dateSubtitle() {
    return DateFormat('EEEE, MMMM d, y').format(DateTime.now());
  }

  int _daysSinceLastOpen() {
    final lastOpened = ref.read(dailyBriefGateProvider).readLastOpenedAt();
    if (lastOpened == null) {
      return 0;
    }
    return DateTime.now().difference(lastOpened).inDays;
  }

  Future<void> _completeBrief({bool discardSession = false}) async {
    if (_isNavigating) {
      return;
    }

    setState(() => _isNavigating = true);

    if (discardSession) {
      await ref.read(focusSessionProvider.notifier).discardActiveSession();
    }

    final gate = ref.read(dailyBriefGateProvider);
    await gate.markShownToday();
    await gate.markOpenedNow();

    if (!mounted) {
      return;
    }

    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: _isResolving || _briefState == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DailyBriefHeader(clockLabel: _clockLabel),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.md,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 640),
                            child: _buildBody(colorScheme),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: _buildActions(colorScheme),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    return switch (_briefState!) {
      DailyBriefState.returningAfterAbsence => _buildReturningBody(colorScheme),
      DailyBriefState.resumeSession => _buildResumeBody(colorScheme),
      DailyBriefState.emptyDay => _buildEmptyDayBody(colorScheme),
      DailyBriefState.dailyBrief => _buildDefaultBody(colorScheme),
    };
  }

  Widget _buildGreeting(ColorScheme colorScheme, {String? title}) {
    final heading = title ?? _timeAwareGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _briefState == DailyBriefState.returningAfterAbsence
              ? "It's been ${_daysSinceLastOpen()} days."
              : _dateSubtitle(),
          style: AppTypography.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildDefaultBody(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildGreeting(colorScheme),
        _buildMissionHero(colorScheme),
        const SizedBox(height: AppSpacing.md),
        _buildProjectContext(colorScheme),
        const SizedBox(height: AppSpacing.lg),
        _buildYesterdayStrip(colorScheme),
      ],
    );
  }

  Widget _buildResumeBody(ColorScheme colorScheme) {
    final task = _interruptedTask;
    final domainColor =
        task == null ? colorScheme.primary : context.domainColor(task.domain);
    final progress =
        (_interruptedElapsedSeconds / deepWorkGoalSeconds).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildGreeting(colorScheme),
        _BriefCard(
          borderColor: domainColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SESSION INTERRUPTED',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.priorityHigh,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task?.title ?? 'Unknown task',
                          style: AppTypography.headingMedium.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${formatFocusClock(_interruptedElapsedSeconds)} elapsed',
                          style: AppTypography.labelLarge.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 4,
                          backgroundColor:
                              colorScheme.outlineVariant.withValues(alpha: 0.3),
                          color: domainColor,
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildProjectContext(colorScheme),
        const SizedBox(height: AppSpacing.lg),
        _buildYesterdayStrip(colorScheme),
      ],
    );
  }

  Widget _buildEmptyDayBody(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildGreeting(colorScheme),
        _BriefCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TODAY'S MISSION",
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Nothing scheduled yet.',
                style: AppTypography.headingMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Decide what matters today.',
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _BriefCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SUGGESTED ACTIONS',
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _SuggestionRow(
                icon: Icons.list_alt_outlined,
                label: 'Plan Your Day (Backlog)',
              ),
              _SuggestionRow(
                icon: Icons.architecture_outlined,
                label: 'Continue a Project (Projects)',
              ),
              _SuggestionRow(
                icon: Icons.account_tree_outlined,
                label: 'Review Pipeline (Pipeline)',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildYesterdayStrip(colorScheme),
      ],
    );
  }

  Widget _buildReturningBody(ColorScheme colorScheme) {
    final status = _absenceStatus!;
    final urgent = status.overdueTaskCount > 0;
    final borderColor =
        urgent ? AppColors.priorityCritical : colorScheme.primary;

    String recommendationTitle;
    String recommendationBody;
    if (status.overdueTaskCount > 0 && status.mostOverdueTask != null) {
      recommendationTitle = status.mostOverdueTask!.title;
      recommendationBody = 'Address overdue work first.';
    } else if (status.weeklyReviewPending) {
      recommendationTitle = 'Weekly review pending';
      recommendationBody = 'Complete your weekly review.';
    } else if (status.topActiveProject != null) {
      recommendationTitle = status.topActiveProject!.name;
      recommendationBody =
          status.topActiveProject!.nextAction ?? 'Continue active project work.';
    } else {
      recommendationTitle = 'Re-engage with your system';
      recommendationBody = 'Pick one priority and start.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildGreeting(colorScheme, title: 'Welcome back, ${_greetingName()}.'),
        _BriefCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STATUS UPDATE',
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _StatusRow(
                label: 'Overdue tasks',
                value: '${status.overdueTaskCount}',
                valueColor: status.overdueTaskCount > 0
                    ? AppColors.priorityCritical
                    : colorScheme.onSurfaceVariant,
              ),
              _StatusRow(
                label: 'Active projects',
                value: '${status.activeProjectCount}',
                valueColor: colorScheme.primary,
              ),
              _StatusRow(
                label: 'Weekly review',
                value: status.weeklyReviewPending ? 'Pending' : 'Complete',
                valueColor: status.weeklyReviewPending
                    ? AppColors.priorityHigh
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _BriefCard(
          borderColor: borderColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RECOMMENDATION',
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                recommendationTitle,
                style: AppTypography.headingMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                recommendationBody,
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Text(
            'Last active: ${_daysSinceLastOpen()} days ago',
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionHero(ColorScheme colorScheme) {
    final task = _topTask;
    final todayCount = ref.read(todayTasksProvider).value?.length ?? 0;
    final borderColor =
        task == null ? colorScheme.primary : context.domainColor(task.domain);

    return _BriefCard(
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S MISSION",
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (task != null) ...[
            Text(
              task.title,
              style: AppTypography.headingMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            if (task.estimatedDurationMinutes != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Est. ${task.estimatedDurationMinutes} min',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ] else
            Text(
              '$todayCount tasks queued for today',
              style: AppTypography.headingMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProjectContext(ColorScheme colorScheme) {
    final project = _activeProject;

    return _BriefCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVE PROJECT',
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (project == null)
            Text(
              'No active projects. Start one from Projects.',
              style: AppTypography.bodyLarge.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    project.name,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.1),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'NEXT ACTION',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              project.nextAction ?? 'Define the next action for this project.',
              style: AppTypography.bodyLarge.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildYesterdayStrip(ColorScheme colorScheme) {
    final summary = _yesterday;
    if (summary == null) {
      return const SizedBox.shrink();
    }

    final hoursLabel = summary.focusHours >= 1
        ? '${summary.focusHours.toStringAsFixed(1)}h focus'
        : '${(summary.focusHours * 60).round()}m focus';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YESTERDAY',
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${summary.tasksCompleted} tasks  ·  $hoursLabel  ·  '
          '${summary.sessionCount} sessions',
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(ColorScheme colorScheme) {
    if (_briefState == DailyBriefState.resumeSession) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: _isNavigating ? null : () => _completeBrief(),
            child: const Text('Resume Session →'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: _isNavigating
                ? null
                : () => _completeBrief(discardSession: true),
            child: const Text('Discard Session'),
          ),
        ],
      );
    }

    final label = switch (_briefState!) {
      DailyBriefState.emptyDay => 'Plan My Day →',
      DailyBriefState.returningAfterAbsence => 'Re-engage →',
      _ => 'Enter Execution Mode →',
    };

    return FilledButton(
      onPressed: _isNavigating ? null : () => _completeBrief(),
      child: Text(label),
    );
  }
}

class _DailyBriefHeader extends StatelessWidget {
  const _DailyBriefHeader({required this.clockLabel});

  final String clockLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(Icons.terminal, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'CIARA OS',
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          Text(
            clockLabel,
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BriefCard extends StatelessWidget {
  const _BriefCard({
    required this.child,
    this.borderColor,
  });

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: borderColor == null
              ? null
              : Border(left: BorderSide(color: borderColor!, width: 4)),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: borderColor == null ? 0 : AppSpacing.sm),
          child: child,
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyLarge.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: AppTypography.labelLarge.copyWith(
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
