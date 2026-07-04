import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/execution_day_quality.dart';
import 'package:ciaraos/models/execution_insight.dart';
import 'package:ciaraos/models/reflection_bullet.dart';
import 'package:ciaraos/models/weekly_execution_metrics.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:ciaraos/utils/domain_icons.dart';

/// Structured system reflection bullets for the review debrief card.
abstract final class SystemReflectionGenerator {
  static List<ReflectionBullet> generate({
    required WeeklyExecutionMetrics metrics,
    required List<ExecutionInsight> insights,
  }) {
    final bullets = <ReflectionBullet>[
      _summaryBullet(metrics),
      _insightBullet(insights),
      _focusBullet(metrics, insights),
    ];

    return bullets.where((bullet) => bullet.segments.isNotEmpty).toList();
  }

  static ReflectionBullet _summaryBullet(WeeklyExecutionMetrics metrics) {
    final taskCount = metrics.tasksCompleted;
    final taskLabel = taskCount == 1 ? 'task' : 'tasks';
    final deepWork = formatDurationMinutes(metrics.deepWorkSeconds);

    final segments = <ReflectionSegment>[
      const ReflectionSegment('This week you completed '),
      ReflectionSegment('$taskCount $taskLabel', bold: true),
      const ReflectionSegment(' across '),
      ReflectionSegment('$deepWork of Deep Work', bold: true),
      const ReflectionSegment('. '),
    ];

    if (metrics.planningAccuracy != null) {
      segments.add(
        ReflectionSegment(
          'Planning accuracy reached ${metrics.planningAccuracy!.round()}%',
        ),
      );
    } else {
      segments.add(
        const ReflectionSegment('Planning data is still forming'),
      );
    }

    final strongestDays = metrics.timeline
        .where((day) => day.quality == ExecutionDayQuality.strong)
        .map((day) => day.label.toUpperCase())
        .toList();

    if (strongestDays.isNotEmpty) {
      segments.add(
        ReflectionSegment(
          ', with your strongest execution landing on ${strongestDays.join(', ')}',
        ),
      );
    } else {
      segments.add(
        const ReflectionSegment(
          ', with execution spread unevenly across the week',
        ),
      );
    }

    segments.add(const ReflectionSegment('.'));

    return ReflectionBullet(segments);
  }

  static ReflectionBullet _insightBullet(List<ExecutionInsight> insights) {
    if (insights.isEmpty) {
      return const ReflectionBullet([
        ReflectionSegment(
          'Continue building execution data for richer weekly analysis.',
        ),
      ]);
    }

    final morning = insights
        .where((insight) => insight.title == 'Morning Productivity')
        .toList();
    final primary = morning.isNotEmpty ? morning.first : insights.first;

    if (primary.title == 'Morning Productivity') {
      return ReflectionBullet([
        ReflectionSegment(primary.description, bold: true),
        ReflectionSegment(
          ' ${primary.recommendation}',
        ),
      ]);
    }

    return ReflectionBullet([
      ReflectionSegment(primary.description),
      if (primary.recommendation.isNotEmpty)
        ReflectionSegment(' ${primary.recommendation}'),
    ]);
  }

  static ReflectionBullet _focusBullet(
    WeeklyExecutionMetrics metrics,
    List<ExecutionInsight> insights,
  ) {
    final focusTarget = _focusTarget(metrics, insights);
    final segments = <ReflectionSegment>[
      const ReflectionSegment('Focus next week on '),
      ReflectionSegment(focusTarget, italic: true),
    ];

    final dominantDomain = _dominantDomain(metrics);
    if (dominantDomain != null) {
      final label = _domainDisplayName(dominantDomain);
      segments.add(
        ReflectionSegment(
          '. Domain coverage is currently lopsided toward $label',
        ),
      );
    } else {
      segments.add(
        const ReflectionSegment('. Domain coverage is balanced this week'),
      );
    }

    segments.add(const ReflectionSegment('.'));

    return ReflectionBullet(segments);
  }

  static String _focusTarget(
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

  static Domain? _dominantDomain(WeeklyExecutionMetrics metrics) {
    if (metrics.completedTasks.length < 3) {
      return null;
    }

    final counts = <Domain, int>{};
    for (final task in metrics.completedTasks) {
      counts[task.domain] = (counts[task.domain] ?? 0) + 1;
    }

    if (counts.isEmpty) {
      return null;
    }

    final total = metrics.completedTasks.length;
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;

    if (top.value / total >= 0.5) {
      return top.key;
    }
    return null;
  }

  static String _domainDisplayName(Domain domain) {
    final label = domainLabel(domain);
    if (label.isEmpty) {
      return label;
    }
    return '${label[0]}${label.substring(1).toLowerCase()}';
  }
}
