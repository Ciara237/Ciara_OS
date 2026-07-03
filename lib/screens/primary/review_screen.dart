import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/weekly_debrief.dart';
import 'package:ciaraos/models/weekly_review.dart';
import 'package:ciaraos/providers/csv_export_provider.dart';
import 'package:ciaraos/providers/focus_session_repository_provider.dart';
import 'package:ciaraos/providers/pdf_export_provider.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/providers/weekly_debrief_providers.dart';
import 'package:ciaraos/providers/weekly_review_providers.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/review_stats_utils.dart';
import 'package:ciaraos/widgets/export/pdf_export_sheets.dart';
import 'package:ciaraos/widgets/review/next_actions_checklist.dart';
import 'package:ciaraos/widgets/review/reflection_card.dart';
import 'package:ciaraos/widgets/review/review_card.dart';
import 'package:ciaraos/widgets/review/review_screen_header.dart';
import 'package:ciaraos/widgets/review/weekly_narrative_card.dart';
import 'package:ciaraos/widgets/today/today_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _reflectionWorkedHint =
    'Document the wins, the completed sprints, and the systems that held firm...';
const _reflectionSlowedHint =
    'Analyze the friction points, the missed targets, and the external distractions...';
const _reflectionImprovementHint =
    'One concrete change to protect execution quality next week...';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late final TextEditingController _whatWorkedController;
  late final TextEditingController _whatSlowedController;
  late final TextEditingController _improvementController;
  late final TextEditingController _newActionController;
  final List<NextActionItem> _nextActions = [];
  bool _prioritiesSeeded = false;
  bool _reflectionSeeded = false;

  @override
  void initState() {
    super.initState();
    _whatWorkedController = TextEditingController();
    _whatSlowedController = TextEditingController();
    _improvementController = TextEditingController();
    _newActionController = TextEditingController();
  }

  @override
  void dispose() {
    _whatWorkedController.dispose();
    _whatSlowedController.dispose();
    _improvementController.dispose();
    _newActionController.dispose();
    super.dispose();
  }

  void _seedFromExistingReview(WeeklyReview? review) {
    if (_reflectionSeeded || review == null) {
      return;
    }
    _reflectionSeeded = true;
    _whatWorkedController.text = review.whatWorked ?? '';
    _whatSlowedController.text = review.whatSlowedDown ?? '';
    _improvementController.text = review.improvementForNextWeek ?? '';
    if (review.nextActions.isNotEmpty) {
      _nextActions.addAll(
        review.nextActions.map(
          (text) => NextActionItem(text: text, checked: false),
        ),
      );
      _prioritiesSeeded = true;
    }
  }

  void _seedPriorities(List<SuggestedPriority> suggestions) {
    if (_prioritiesSeeded || suggestions.isEmpty) {
      return;
    }
    _prioritiesSeeded = true;
    setState(() {
      for (final suggestion in suggestions) {
        _nextActions.add(
          NextActionItem(
            text: suggestion.title,
            checked: false,
            domain: suggestion.domainName == null
                ? null
                : Domain.values.byName(suggestion.domainName!),
          ),
        );
      }
    });
  }

  void _exportLogs() {
    showReviewExportSheet(
      context: context,
      onExportPdf: _exportWeeklyReviewPdf,
      onExportCsv: _exportWeekTasksCsv,
    );
  }

  Future<WeeklyReview> _buildReviewForExport() async {
    final debrief = ref.read(weeklyDebriefProvider).value;
    if (debrief == null) {
      throw StateError('Execution data is not loaded yet.');
    }

    final repository = ref.read(weeklyReviewRepositoryProvider);
    final weekOf = mondayOfWeek(DateTime.now());
    final existing = await repository.getByWeek(weekOf);
    final now = DateTime.now();

    String? trimmedOrNull(TextEditingController controller) {
      final value = controller.text.trim();
      return value.isEmpty ? null : value;
    }

    return WeeklyReview(
      id: existing?.id ?? 0,
      weekOf: weekOf,
      whatWorked: trimmedOrNull(_whatWorkedController),
      whatSlowedDown: trimmedOrNull(_whatSlowedController),
      improvementForNextWeek: trimmedOrNull(_improvementController),
      nextActions: _nextActions.map((item) => item.text).toList(),
      startedRate: debrief.metrics.taskCompletionRate,
      totalTasks: debrief.metrics.tasksInScope,
      startedTasks: debrief.metrics.tasksCompleted,
      focusScore: debrief.executionScore,
      executionScore: debrief.executionScore,
      weeklyNarrative: debrief.narrative,
      insights: debrief.insights,
      locked: existing?.locked ?? false,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> _exportWeeklyReviewPdf() async {
    try {
      final review = await _buildReviewForExport();
      final tasks = await ref.read(weekTasksProvider(review.weekOf).future);
      final sessions = await ref
          .read(focusSessionRepositoryProvider)
          .getSessionsForWeek(review.weekOf);
      await ref.read(pdfExportServiceProvider).exportWeeklyReview(
            review: review,
            tasksThisWeek: tasks,
            sessionsThisWeek: sessions,
          );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $error')),
        );
      }
      rethrow;
    }
  }

  Future<void> _exportWeekTasksCsv() async {
    try {
      final weekOf = mondayOfWeek(DateTime.now());
      final tasks = await ref.read(weekTasksProvider(weekOf).future);
      await ref.read(csvExportServiceProvider).exportTasks(
            tasks: tasks,
            periodLabel: reviewWeekRangeLabel(weekOf),
          );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $error')),
        );
      }
      rethrow;
    }
  }

  void _toggleNextAction(int index) {
    setState(() {
      _nextActions[index] = _nextActions[index].copyWith(
        checked: !_nextActions[index].checked,
      );
    });
  }

  void _addNextAction() {
    final text = _newActionController.text.trim();
    if (text.isEmpty) {
      return;
    }
    setState(() {
      _nextActions.add(NextActionItem(text: text, checked: false));
      _newActionController.clear();
    });
  }

  bool _hasReflectionText() {
    return [
      _whatWorkedController,
      _whatSlowedController,
      _improvementController,
    ].any((controller) => controller.text.trim().isNotEmpty);
  }

  Future<void> _finalizeReview() async {
    if (!_hasReflectionText()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one reflection before finalizing.'),
        ),
      );
      return;
    }

    final debrief = ref.read(weeklyDebriefProvider).value;
    if (debrief == null) {
      return;
    }

    final repository = ref.read(weeklyReviewRepositoryProvider);
    final weekOf = mondayOfWeek(DateTime.now());
    final existing = await repository.getByWeek(weekOf);
    final now = DateTime.now();

    String? trimmedOrNull(TextEditingController controller) {
      final value = controller.text.trim();
      return value.isEmpty ? null : value;
    }

    final review = WeeklyReview(
      id: existing?.id ?? 0,
      weekOf: weekOf,
      whatWorked: trimmedOrNull(_whatWorkedController),
      whatSlowedDown: trimmedOrNull(_whatSlowedController),
      improvementForNextWeek: trimmedOrNull(_improvementController),
      nextActions: _nextActions.map((item) => item.text).toList(),
      startedRate: debrief.metrics.taskCompletionRate,
      totalTasks: debrief.metrics.tasksInScope,
      startedTasks: debrief.metrics.tasksCompleted,
      focusScore: debrief.executionScore,
      executionScore: debrief.executionScore,
      weeklyNarrative: debrief.narrative,
      insights: debrief.insights,
      locked: true,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (existing == null) {
      await repository.insert(review.toCompanion(forInsert: true));
    } else {
      await repository.update(review.toCompanion());
    }

    ref.invalidate(currentWeekReviewProvider);
    ref.invalidate(weeklyDebriefProvider);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Executive Debrief finalized.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final debriefAsync = ref.watch(weeklyDebriefProvider);
    final existingReviewAsync = ref.watch(currentWeekReviewProvider);

    existingReviewAsync.whenData(_seedFromExistingReview);

    final isWide = MediaQuery.sizeOf(context).width >= 1024;
    final horizontalPadding =
        isWide ? AppSpacing.reviewPadding : AppSpacing.lg;

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        children: [
          const TodayHeader(),
          Expanded(
            child: debriefAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'Could not load execution data.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              data: (debrief) {
                _seedPriorities(debrief.suggestedPriorities);
                final weekMonday = mondayOfWeek(DateTime.now());

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSpacing.containerMax,
                    ),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        AppSpacing.lg,
                        horizontalPadding,
                        AppSpacing.xxl,
                      ),
                      children: [
                        ReviewScreenHeader(
                          weekMonday: weekMonday,
                          onExport: _exportLogs,
                          onFinalize: _finalizeReview,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _CompactExecutionScore(debrief: debrief),
                        const SizedBox(height: AppSpacing.md),
                        _CompactMetricsStrip(debrief: debrief),
                        const SizedBox(height: AppSpacing.reviewGap),
                        WeeklyNarrativeCard(narrative: debrief.narrative),
                        const SizedBox(height: AppSpacing.reviewGap),
                        if (isWide)
                          _wideReflectionRow()
                        else
                          _narrowReflectionColumn(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _wideReflectionRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 8,
          child: _reflectionGrid(isWide: true),
        ),
        const SizedBox(width: AppSpacing.reviewGap),
        Expanded(
          flex: 4,
          child: NextActionsChecklist(
            items: _nextActions,
            newActionController: _newActionController,
            onToggle: _toggleNextAction,
            onAdd: _addNextAction,
          ),
        ),
      ],
    );
  }

  Widget _narrowReflectionColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _reflectionGrid(isWide: false),
        const SizedBox(height: AppSpacing.reviewGap),
        NextActionsChecklist(
          items: _nextActions,
          newActionController: _newActionController,
          onToggle: _toggleNextAction,
          onAdd: _addNextAction,
        ),
      ],
    );
  }

  Widget _reflectionGrid({required bool isWide}) {
    final worked = ReflectionCard(
      label: 'What went well?',
      hint: _reflectionWorkedHint,
      controller: _whatWorkedController,
    );
    final slowed = ReflectionCard(
      label: 'What slowed you down?',
      hint: _reflectionSlowedHint,
      controller: _whatSlowedController,
    );
    final improvement = ReflectionCard(
      label: 'Improvement for next week',
      hint: _reflectionImprovementHint,
      controller: _improvementController,
      spanFullWidth: true,
    );

    if (isWide) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: worked),
              const SizedBox(width: AppSpacing.reviewGap),
              Expanded(child: slowed),
            ],
          ),
          const SizedBox(height: AppSpacing.reviewGap),
          improvement,
        ],
      );
    }

    return Column(
      children: [
        worked,
        const SizedBox(height: AppSpacing.reviewGap),
        slowed,
        const SizedBox(height: AppSpacing.reviewGap),
        improvement,
      ],
    );
  }
}

class _CompactExecutionScore extends StatelessWidget {
  const _CompactExecutionScore({required this.debrief});

  final WeeklyDebrief debrief;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final score = debrief.executionScore.round();

    return ReviewCard(
      child: Row(
        children: [
          Text(
            '$score%',
            style: AppTypography.headingLarge.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Execution Score',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMetricsStrip extends StatelessWidget {
  const _CompactMetricsStrip({required this.debrief});

  final WeeklyDebrief debrief;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final metrics = debrief.metrics;
    final startedRate = (metrics.taskCompletionRate * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReviewCard(
          child: Row(
            children: [
              Expanded(
                child: _MetricCell(
                  label: 'Started rate',
                  value: '$startedRate%',
                ),
              ),
              Expanded(
                child: _MetricCell(
                  label: 'Tasks completed',
                  value: '${metrics.tasksCompleted}',
                ),
              ),
              Expanded(
                child: _MetricCell(
                  label: 'Focus hours',
                  value: formatFocusUptime(metrics.deepWorkSeconds),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.go('/analytics/trends'),
            child: Text(
              'View Full Analytics →',
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

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.headingMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
