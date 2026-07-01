import 'package:ciaraos/models/execution_insight.dart';
import 'package:ciaraos/models/weekly_execution_metrics.dart';

/// Full Executive Debrief package for a review week.
class WeeklyDebrief {
  const WeeklyDebrief({
    required this.metrics,
    required this.executionScore,
    required this.scoreDelta,
    required this.hasPriorWeekData,
    required this.insights,
    required this.narrative,
    required this.suggestedPriorities,
  });

  final WeeklyExecutionMetrics metrics;
  final double executionScore;
  final double? scoreDelta;
  final bool hasPriorWeekData;
  final List<ExecutionInsight> insights;
  final String narrative;
  final List<SuggestedPriority> suggestedPriorities;
}

class SuggestedPriority {
  const SuggestedPriority({
    required this.title,
    this.domainName,
  });

  final String title;
  final String? domainName;
}
