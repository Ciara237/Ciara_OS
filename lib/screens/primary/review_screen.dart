import 'package:ciaraos/models/weekly_review.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/providers/weekly_review_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/review_stats_utils.dart';
import 'package:ciaraos/widgets/review/advisory_callout.dart';
import 'package:ciaraos/widgets/review/lock_reflection_button.dart';
import 'package:ciaraos/widgets/review/next_actions_checklist.dart';
import 'package:ciaraos/widgets/review/reflection_card.dart';
import 'package:ciaraos/widgets/review/review_screen_label.dart';
import 'package:ciaraos/widgets/review/weekly_bar_chart.dart';
import 'package:ciaraos/widgets/today/today_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Card-specific accent colors documented here (not domain/theme tokens).
const _reflectionWorkedColor = Color(0xFF10B981);
const _reflectionAutomateColor = Color(0xFFF59E0B);

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late final TextEditingController _whatWorkedController;
  late final TextEditingController _whatFailedController;
  late final TextEditingController _whatToAutomateController;
  late final TextEditingController _whatToCutController;
  late final TextEditingController _newActionController;
  final List<NextActionItem> _nextActions = [];

  @override
  void initState() {
    super.initState();
    _whatWorkedController = TextEditingController();
    _whatFailedController = TextEditingController();
    _whatToAutomateController = TextEditingController();
    _whatToCutController = TextEditingController();
    _newActionController = TextEditingController();
  }

  @override
  void dispose() {
    _whatWorkedController.dispose();
    _whatFailedController.dispose();
    _whatToAutomateController.dispose();
    _whatToCutController.dispose();
    _newActionController.dispose();
    super.dispose();
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export coming in a future update.')),
    );
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
      _whatFailedController,
      _whatToAutomateController,
      _whatToCutController,
    ].any((controller) => controller.text.trim().isNotEmpty);
  }

  Future<void> _lockReflection({
    required double startedRate,
    required int totalTasks,
    required int startedTasks,
  }) async {
    if (!_hasReflectionText()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one reflection before locking.'),
        ),
      );
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
      whatFailed: trimmedOrNull(_whatFailedController),
      whatToAutomate: trimmedOrNull(_whatToAutomateController),
      whatToCut: trimmedOrNull(_whatToCutController),
      nextActions: _nextActions.map((item) => item.text).toList(),
      startedRate: startedRate,
      totalTasks: totalTasks,
      startedTasks: startedTasks,
      focusScore: startedRate * 100,
      locked: true,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (existing == null) {
      await repository.insert(review.toCompanion(forInsert: true));
    } else {
      await repository.update(review.toCompanion());
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Weekly reflection locked.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentMonday = mondayOfWeek(DateTime.now());
    final previousMonday = currentMonday.subtract(const Duration(days: 7));

    final thisWeekTasks = ref.watch(weekTasksProvider(currentMonday));
    final lastWeekTasks = ref.watch(weekTasksProvider(previousMonday));

    final tasks = thisWeekTasks.value ?? const [];
    final lastWeekData = lastWeekTasks.value ?? const [];
    final statsLoadFailed = thisWeekTasks.hasError || lastWeekTasks.hasError;
    final isLoading = thisWeekTasks.isLoading && !thisWeekTasks.hasValue;

    if (isLoading) {
      return ColoredBox(
        color: colorScheme.surface,
        child: const Column(
          children: [
            TodayHeader(),
            Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }

    final hasPriorWeekData = lastWeekData.isNotEmpty;
    final startedRate = tasks.isEmpty ? null : startedRateForTasks(tasks);
    final focusScorePercent =
        ((startedRate ?? 0) * 100).round().clamp(0, 100);
    final deltaPercent = hasPriorWeekData
        ? (startedRateForTasks(tasks) - startedRateForTasks(lastWeekData)) * 100
        : null;
    final dailyRates = dailyStartedRates(tasks, currentMonday);
    final todayIndex = todayWeekdayIndex(currentMonday);

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        children: [
          const TodayHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                if (statsLoadFailed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      'Could not load weekly stats. Showing empty week.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ReviewScreenLabel(
                  focusScorePercent: focusScorePercent,
                  deltaPercent: deltaPercent,
                  hasPriorWeekData: hasPriorWeekData,
                  insightText: insightForDelta(deltaPercent),
                ),
                const SizedBox(height: AppSpacing.xl),
                WeeklyBarChart(
                  dailyRates: dailyRates,
                  todayIndex: todayIndex,
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: _exportLogs,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                      side: BorderSide(color: colorScheme.onSurfaceVariant),
                    ),
                    child: const Text('↓ EXPORT LOGS'),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ReflectionCard(
                  icon: Icons.check_circle_outline,
                  iconColor: _reflectionWorkedColor,
                  label: 'What Worked?',
                  hint:
                      'Document the wins, the completed sprints, and the systems that held firm...',
                  controller: _whatWorkedController,
                ),
                const SizedBox(height: AppSpacing.lg),
                ReflectionCard(
                  icon: Icons.cancel_outlined,
                  iconColor: colorScheme.error,
                  label: 'What Failed?',
                  labelColor: colorScheme.error,
                  hint:
                      'Analyze the friction points, the missed targets, and the external distractions...',
                  controller: _whatFailedController,
                ),
                const SizedBox(height: AppSpacing.lg),
                ReflectionCard(
                  icon: Icons.bolt,
                  iconColor: _reflectionAutomateColor,
                  label: 'Automatic Systems?',
                  hint:
                      'Identify repetitive tasks that should be scripted, delegated, or standardized...',
                  controller: _whatToAutomateController,
                ),
                const SizedBox(height: AppSpacing.lg),
                ReflectionCard(
                  icon: Icons.content_cut,
                  iconColor: colorScheme.onSurfaceVariant,
                  label: 'What Should Be Cut?',
                  hint:
                      'Locate the low-value activities and the energy vampires. What stops today?',
                  controller: _whatToCutController,
                ),
                const SizedBox(height: AppSpacing.xl),
                NextActionsChecklist(
                  items: _nextActions,
                  newActionController: _newActionController,
                  onToggle: _toggleNextAction,
                  onAdd: _addNextAction,
                ),
                const SizedBox(height: AppSpacing.xl),
                AdvisoryCallout(
                  bodyText: advisoryForStartedRate(startedRate),
                ),
                const SizedBox(height: AppSpacing.lg),
                LockReflectionButton(
                  onLock: () => _lockReflection(
                    startedRate: startedRate ?? 0,
                    totalTasks: tasks.length,
                    startedTasks: tasks.where((task) => task.started).length,
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
