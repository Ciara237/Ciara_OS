import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/planning_accuracy_data.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/utils/planning_accuracy_utils.dart';

class PlanningAccuracyService {
  static const minTasksForInsights = 5;
  static const _trendWeekCount = 8;

  PlanningAccuracyData compute(List<Task> tasks) {
    final qualifying = tasks.where(_hasAccuracyData).toList();
    final count = qualifying.length;

    if (count == 0) {
      return PlanningAccuracyData(
        overallAccuracy: null,
        deltaVsPriorPeriod: null,
        summaryText: '',
        byDomain: const [],
        worstEstimates: const [],
        eightWeekTrend: _emptyTrend(),
        tip: null,
        qualifyingTaskCount: count,
        hasEnoughData: false,
      );
    }

    final overall = _meanAccuracy(qualifying);
    final trend = _buildEightWeekTrend(qualifying);
    final delta = _deltaFromTrend(trend);
    final byDomain = _domainBreakdown(qualifying);
    final worst = _worstEstimates(qualifying);
    final avgGap = _meanGapMinutes(qualifying);

    return PlanningAccuracyData(
      overallAccuracy: overall,
      deltaVsPriorPeriod: delta,
      summaryText: _buildSummary(overall, avgGap),
      byDomain: byDomain,
      worstEstimates: worst,
      eightWeekTrend: trend,
      tip: _buildTip(byDomain, avgGap, overall),
      qualifyingTaskCount: count,
      hasEnoughData: count >= minTasksForInsights,
    );
  }

  static bool _hasAccuracyData(Task task) {
    return taskQualifiesForPlanningAccuracy(task);
  }

  static double? _meanAccuracy(List<Task> tasks) {
    if (tasks.isEmpty) {
      return null;
    }
    final sum = tasks.fold<double>(
      0,
      (total, task) => total + task.planningAccuracy!,
    );
    return sum / tasks.length;
  }

  static double _meanGapMinutes(List<Task> tasks) {
    if (tasks.isEmpty) {
      return 0;
    }
    final sum = tasks.fold<double>(0, (total, task) {
      final actual = task.totalFocusedSeconds / 60;
      return total + (actual - task.estimatedDurationMinutes!);
    });
    return sum / tasks.length;
  }

  static List<DomainAccuracy> _domainBreakdown(List<Task> tasks) {
    final results = <DomainAccuracy>[];

    for (final domain in Domain.values) {
      final domainTasks = tasks.where((task) => task.domain == domain).toList();
      if (domainTasks.isEmpty) {
        continue;
      }

      final accuracy = _meanAccuracy(domainTasks)!;
      final avgGap = _meanGapMinutes(domainTasks);

      results.add(
        DomainAccuracy(
          domain: domain,
          accuracyPercent: accuracy,
          avgOverUnderMinutes: avgGap,
          taskCount: domainTasks.length,
        ),
      );
    }

    results.sort((a, b) => b.taskCount.compareTo(a.taskCount));
    return results;
  }

  static List<TaskAccuracyMiss> _worstEstimates(List<Task> tasks) {
    final misses = tasks.map((task) {
      final estimated = task.estimatedDurationMinutes!;
      final actual = (task.totalFocusedSeconds / 60).round();
      final gap = actual - estimated;
      final gapPercent = estimated == 0 ? 0.0 : (gap / estimated) * 100;

      return TaskAccuracyMiss(
        taskId: task.id,
        title: task.title,
        domain: task.domain,
        estimatedMinutes: estimated,
        actualMinutes: actual,
        gapMinutes: gap.toDouble(),
        gapPercent: gapPercent,
        planningAccuracy: task.planningAccuracy!,
      );
    }).toList()
      ..sort(
        (a, b) => b.gapMinutes.abs().compareTo(a.gapMinutes.abs()),
      );

    return misses.take(5).toList();
  }

  static List<WeeklyAccuracyPoint> _buildEightWeekTrend(List<Task> tasks) {
    final now = DateTime.now();
    final currentWeekStart = _startOfWeek(now);

    return List.generate(_trendWeekCount, (index) {
      final weeksAgo = _trendWeekCount - 1 - index;
      final weekStart = currentWeekStart.subtract(Duration(days: weeksAgo * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final weekTasks = tasks.where((task) {
        final anchor = task.updatedAt;
        return !anchor.isBefore(weekStart) && anchor.isBefore(weekEnd);
      }).toList();

      return WeeklyAccuracyPoint(
        weekStart: weekStart,
        accuracy: weekTasks.isEmpty ? null : _meanAccuracy(weekTasks),
        taskCount: weekTasks.length,
      );
    });
  }

  static List<WeeklyAccuracyPoint> _emptyTrend() {
    final now = DateTime.now();
    final currentWeekStart = _startOfWeek(now);
    return List.generate(_trendWeekCount, (index) {
      final weeksAgo = _trendWeekCount - 1 - index;
      return WeeklyAccuracyPoint(
        weekStart: currentWeekStart.subtract(Duration(days: weeksAgo * 7)),
        accuracy: null,
        taskCount: 0,
      );
    });
  }

  static double? _deltaFromTrend(List<WeeklyAccuracyPoint> trend) {
    if (trend.length < _trendWeekCount) {
      return null;
    }

    final recent = trend.sublist(4);
    final prior = trend.sublist(0, 4);
    final recentValues =
        recent.where((p) => p.accuracy != null).map((p) => p.accuracy!).toList();
    final priorValues =
        prior.where((p) => p.accuracy != null).map((p) => p.accuracy!).toList();

    if (recentValues.isEmpty || priorValues.isEmpty) {
      return null;
    }

    final recentAvg =
        recentValues.reduce((a, b) => a + b) / recentValues.length;
    final priorAvg = priorValues.reduce((a, b) => a + b) / priorValues.length;
    return recentAvg - priorAvg;
  }

  static String _buildSummary(double? overall, double avgGapMinutes) {
    if (overall == null) {
      return '';
    }

    final rounded = overall.round();
    if (avgGapMinutes.abs() < 5) {
      return 'Your estimation precision is holding at $rounded%. Estimates are closely aligned with actual focused time.';
    }

    if (avgGapMinutes > 0) {
      final minutes = avgGapMinutes.round();
      return 'Your estimation precision is at $rounded%. You are consistently underestimating tasks by an average of $minutes minutes.';
    }

    final minutes = avgGapMinutes.abs().round();
    return 'Your estimation precision is at $rounded%. You are finishing tasks about $minutes minutes faster than estimated on average.';
  }

  static String? _buildTip(
    List<DomainAccuracy> byDomain,
    double avgGapMinutes,
    double? overall,
  ) {
    DomainAccuracy? engineering;
    for (final entry in byDomain) {
      if (entry.domain == Domain.engineering) {
        engineering = entry;
        break;
      }
    }
    if (engineering != null && engineering.accuracyPercent < 60) {
      return 'Engineering tasks take longer than estimated. Add a 30% buffer when planning deep-work blocks in ${domainLabel(Domain.engineering).toLowerCase()}.';
    }

    if (avgGapMinutes >= 10) {
      return 'Apply a buffer rule of 1.5× to tasks where you routinely underestimate. Historical data shows discovery work often adds meaningful time beyond the first estimate.';
    }

    if (overall != null && overall >= 80) {
      return 'Strong calibration overall. Keep logging estimates on new tasks so trends stay reliable as your workload shifts.';
    }

    final weakest = byDomain.isEmpty
        ? null
        : byDomain.reduce(
            (a, b) => a.accuracyPercent < b.accuracyPercent ? a : b,
          );
    if (weakest != null && weakest.accuracyPercent < 70) {
      return '${domainLabel(weakest.domain)} estimates are the weakest area (${weakest.accuracyPercent.round()}% accuracy). Review recent misses before scheduling the next block.';
    }

    return 'Complete tasks with time estimates to keep sharpening your planning accuracy signal.';
  }

  static DateTime _startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }
}
