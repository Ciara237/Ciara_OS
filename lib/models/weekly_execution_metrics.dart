import 'package:ciaraos/models/execution_timeline_day.dart';
import 'package:ciaraos/models/task.dart';

/// Aggregated execution data for a single review week.
class WeeklyExecutionMetrics {
  const WeeklyExecutionMetrics({
    required this.weekOf,
    required this.tasksCompleted,
    required this.tasksInScope,
    required this.deepWorkSeconds,
    required this.focusSessionCount,
    required this.planningAccuracy,
    required this.longestStreak,
    required this.biggestWin,
    required this.averageFocusQuality,
    required this.dailyFocusSeconds,
    required this.timeline,
    required this.completedTasks,
    required this.sessionsThisWeek,
    required this.contextSwitchDays,
  });

  final DateTime weekOf;
  final int tasksCompleted;
  final int tasksInScope;
  final int deepWorkSeconds;
  final int focusSessionCount;
  final double? planningAccuracy;
  final int longestStreak;
  final String? biggestWin;
  final double? averageFocusQuality;
  final List<int> dailyFocusSeconds;
  final List<ExecutionTimelineDay> timeline;
  final List<Task> completedTasks;
  final int sessionsThisWeek;
  final int contextSwitchDays;

  double get taskCompletionRate {
    if (tasksInScope <= 0) {
      return tasksCompleted > 0 ? 1 : 0;
    }
    return (tasksCompleted / tasksInScope).clamp(0.0, 1.0);
  }
}
