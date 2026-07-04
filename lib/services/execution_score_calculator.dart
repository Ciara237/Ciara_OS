import 'package:ciaraos/models/weekly_execution_metrics.dart';

/// Encapsulated execution score — formula can evolve without UI changes.
class ExecutionScoreResult {
  const ExecutionScoreResult({
    required this.score,
    required this.components,
  });

  final double score;
  final ExecutionScoreComponents components;
}

class ExecutionScoreComponents {
  const ExecutionScoreComponents({
    required this.taskCompletion,
    required this.deepWorkConsistency,
    required this.planningAccuracy,
    required this.focusQuality,
    required this.streakConsistency,
  });

  final double taskCompletion;
  final double deepWorkConsistency;
  final double planningAccuracy;
  final double focusQuality;
  final double streakConsistency;
}

abstract final class ExecutionScoreCalculator {
  static const _taskWeight = 0.25;
  static const _deepWorkWeight = 0.25;
  static const _planningWeight = 0.20;
  static const _qualityWeight = 0.20;
  static const _streakWeight = 0.10;

  static ExecutionScoreResult calculate(WeeklyExecutionMetrics metrics) {
    final taskCompletion = metrics.taskCompletionRate * 100;

    final daysWithFocus = metrics.dailyFocusSeconds
        .where((seconds) => seconds >= 15 * 60)
        .length;
    final deepWorkConsistency = (daysWithFocus / 7) * 100;

    final planningAccuracy = metrics.planningAccuracy ?? 0;

    final focusQuality = metrics.averageFocusQuality == null
        ? 0.0
        : (metrics.averageFocusQuality! / 4) * 100;

    final streakConsistency =
        (metrics.longestStreak / 7).clamp(0.0, 1.0).toDouble() * 100;

    final score = taskCompletion * _taskWeight +
        deepWorkConsistency * _deepWorkWeight +
        planningAccuracy * _planningWeight +
        focusQuality * _qualityWeight +
        streakConsistency * _streakWeight;

    return ExecutionScoreResult(
      score: score.clamp(0, 100).toDouble(),
      components: ExecutionScoreComponents(
        taskCompletion: taskCompletion,
        deepWorkConsistency: deepWorkConsistency,
        planningAccuracy: planningAccuracy,
        focusQuality: focusQuality,
        streakConsistency: streakConsistency,
      ),
    );
  }

  static String describeScore(double score) {
    if (score >= 80) {
      return 'Strategic performance analysis indicates strong operational '
          'execution. Efficiency exceeds baseline tolerances for current '
          'project complexity.';
    }
    if (score >= 60) {
      return 'Strategic performance analysis indicates a steady operational '
          'baseline. Efficiency is within expected tolerances for current '
          'project complexity.';
    }
    if (score >= 40) {
      return 'Strategic performance analysis indicates uneven execution '
          'patterns. Efficiency is below target tolerances — recalibration '
          'is advised.';
    }
    return 'Strategic performance analysis indicates limited execution '
        'signal this week. Establish consistent focus blocks before scaling '
        'commitments.';
  }
}
