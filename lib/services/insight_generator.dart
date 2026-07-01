import 'package:ciaraos/models/enums/execution_day_quality.dart';
import 'package:ciaraos/models/execution_insight.dart';
import 'package:ciaraos/models/execution_timeline_day.dart';
import 'package:ciaraos/models/focus_session_record.dart';
import 'package:ciaraos/models/weekly_execution_metrics.dart';
import 'package:flutter/material.dart';

/// Deterministic insight generation — designed for future AI replacement.
abstract final class InsightGenerator {
  static List<ExecutionInsight> generate({
    required WeeklyExecutionMetrics metrics,
    required double? scoreDelta,
    required List<FocusSessionRecord> sessions,
  }) {
    final insights = <ExecutionInsight>[];

    if (metrics.planningAccuracy != null && metrics.planningAccuracy! >= 80) {
      insights.add(
        ExecutionInsight(
          title: 'High Planning Accuracy',
          description:
              'Your estimates aligned within ${metrics.planningAccuracy!.round()}% of actual focused time.',
          recommendation:
              'Keep using duration estimates — they are sharpening your execution planning.',
          icon: Icons.track_changes,
          iconColorKind: InsightIconColorKind.primary,
        ),
      );
    }

    final avgSessionLength = _averageSessionLength(sessions);
    if (sessions.length >= 6 && avgSessionLength < 25 * 60) {
      insights.add(
        ExecutionInsight(
          title: 'Frequent Context Switching',
          description:
              '${sessions.length} focus sessions averaged ${(avgSessionLength / 60).round()} minutes each.',
          recommendation:
              'Batch similar work and protect longer blocks before starting new tasks.',
          icon: Icons.shuffle,
          iconColorKind: InsightIconColorKind.tertiary,
        ),
      );
    }

    final morningInsight = _morningProductivityInsight(sessions);
    if (morningInsight != null) {
      insights.add(morningInsight);
    }

    final longest = _longestSession(sessions);
    if (longest != null) {
      final minutes = longest.durationSeconds ~/ 60;
      insights.add(
        ExecutionInsight(
          title: 'Longest Focus Session',
          description:
              'Your deepest block reached $minutes minutes of uninterrupted work.',
          recommendation:
              'Replicate the conditions from that session when scheduling next week.',
          icon: Icons.timer,
          iconColorKind: InsightIconColorKind.secondary,
        ),
      );
    }

    if (scoreDelta != null && scoreDelta > 2) {
      insights.add(
        ExecutionInsight(
          title: 'Improved Execution',
          description:
              'Execution Score rose ${scoreDelta.toStringAsFixed(0)} points versus last week.',
          recommendation:
              'Document what changed — protect those habits entering next week.',
          icon: Icons.trending_up,
          iconColorKind: InsightIconColorKind.primary,
        ),
      );
    } else if (metrics.taskCompletionRate < 0.4 && metrics.tasksInScope > 0) {
      insights.add(
        ExecutionInsight(
          title: 'Completion Gap',
          description:
              'Only ${(metrics.taskCompletionRate * 100).round()}% of in-scope work was completed.',
          recommendation:
              'Reduce active commitments before adding new tasks to the queue.',
          icon: Icons.warning_amber_outlined,
          iconColorKind: InsightIconColorKind.tertiary,
        ),
      );
    }

    final weakDay = _weakestDay(metrics.timeline);
    if (weakDay != null && insights.length < 5) {
      insights.add(
        ExecutionInsight(
          title: 'Execution Dip',
          description:
              '${weakDay.label} showed the weakest execution rhythm this week.',
          recommendation:
              'Protect that day with fewer commitments or a single deep work anchor.',
          icon: Icons.event_busy,
          iconColorKind: InsightIconColorKind.tertiary,
        ),
      );
    }

    return insights.take(5).toList();
  }

  static double _averageSessionLength(List<FocusSessionRecord> sessions) {
    if (sessions.isEmpty) {
      return 0;
    }
    final total =
        sessions.fold<int>(0, (sum, session) => sum + session.durationSeconds);
    return total / sessions.length;
  }

  static ExecutionInsight? _morningProductivityInsight(
    List<FocusSessionRecord> sessions,
  ) {
    var morningSeconds = 0;
    var afternoonSeconds = 0;

    for (final session in sessions) {
      final hour = session.endedAt?.hour ?? session.startedAt.hour;
      if (hour < 12) {
        morningSeconds += session.durationSeconds;
      } else {
        afternoonSeconds += session.durationSeconds;
      }
    }

    if (morningSeconds <= 0 || afternoonSeconds <= 0) {
      return null;
    }

    if (morningSeconds <= afternoonSeconds) {
      return null;
    }

    final lift = ((morningSeconds / afternoonSeconds) - 1) * 100;
    return ExecutionInsight(
      title: 'Morning Productivity',
      description:
          'Deep work output was ${lift.round()}% higher before noon than after.',
      recommendation:
          'Schedule demanding engineering work in morning blocks when possible.',
      icon: Icons.wb_sunny_outlined,
      iconColorKind: InsightIconColorKind.primary,
    );
  }

  static FocusSessionRecord? _longestSession(List<FocusSessionRecord> sessions) {
    if (sessions.isEmpty) {
      return null;
    }
    return sessions.reduce(
      (a, b) => a.durationSeconds >= b.durationSeconds ? a : b,
    );
  }

  static ExecutionTimelineDay? _weakestDay(List<ExecutionTimelineDay> timeline) {
    ExecutionTimelineDay? weakest;
    for (final day in timeline) {
      if (day.quality == ExecutionDayQuality.weak) {
        weakest = day;
        break;
      }
    }
    return weakest;
  }
}
