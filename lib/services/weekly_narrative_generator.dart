import 'package:ciaraos/models/enums/execution_day_quality.dart';
import 'package:ciaraos/models/execution_insight.dart';
import 'package:ciaraos/models/weekly_execution_metrics.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';

/// Template-based weekly narrative — swappable for AI later.
abstract final class WeeklyNarrativeGenerator {
  static String generate({
    required WeeklyExecutionMetrics metrics,
    required double executionScore,
    required List<ExecutionInsight> insights,
  }) {
    final taskCount = metrics.tasksCompleted;
    final deepWork = formatDurationMinutes(metrics.deepWorkSeconds);
    final accuracyText = metrics.planningAccuracy == null
        ? 'planning data is still forming'
        : 'planning accuracy reached ${metrics.planningAccuracy!.round()}%';

    final strongestDay = metrics.timeline
        .where((day) => day.quality == ExecutionDayQuality.strong)
        .map((day) => day.label)
        .toList();
    final strongestText = strongestDay.isEmpty
        ? 'execution was uneven across the week'
        : 'your strongest execution landed on ${strongestDay.join(', ')}';

    final insightSnippet = insights.isEmpty
        ? 'Continue building execution data for richer analysis.'
        : insights.first.description;

    final focusNext = _focusRecommendation(metrics, insights);

    return 'This week you completed $taskCount '
        '${taskCount == 1 ? 'task' : 'tasks'} across $deepWork of Deep Work. '
        '$accuracyText, with $strongestText. '
        '$insightSnippet '
        'Focus next week on $focusNext.';
  }

  static String _focusRecommendation(
    WeeklyExecutionMetrics metrics,
    List<ExecutionInsight> insights,
  ) {
    if (insights.any((i) => i.title == 'Frequent Context Switching')) {
      return 'fewer, longer focus blocks before starting new work';
    }
    if (metrics.taskCompletionRate < 0.5) {
      return 'completing existing work before starting new tasks';
    }
    if (metrics.biggestWin != null) {
      return 'building on momentum from ${metrics.biggestWin}';
    }
    return 'protecting your highest-quality focus windows';
  }
}
