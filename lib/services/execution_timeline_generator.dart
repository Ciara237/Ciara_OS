import 'package:ciaraos/models/enums/execution_day_quality.dart';
import 'package:ciaraos/models/execution_timeline_day.dart';
import 'package:ciaraos/models/focus_session_record.dart';
import 'package:ciaraos/models/task.dart';
abstract final class ExecutionTimelineGenerator {
  static const _dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  static List<ExecutionTimelineDay> generate({
    required DateTime weekMonday,
    required List<Task> completedTasks,
    required List<int> dailyFocusSeconds,
    required List<FocusSessionRecord> sessions,
  }) {
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    final monday = DateTime(
      weekMonday.year,
      weekMonday.month,
      weekMonday.day,
    );

    return List.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final completedOnDay = completedTasks.where((task) {
        final updated = task.updatedAt;
        return !updated.isBefore(dayStart) && updated.isBefore(dayEnd);
      }).length;

      final focusSeconds = dailyFocusSeconds[index];
      final sessionCount = sessions.where((session) {
        final ended = session.endedAt;
        if (ended == null) {
          return false;
        }
        return !ended.isBefore(dayStart) && ended.isBefore(dayEnd);
      }).length;

      final quality = _qualityForDay(
        day: dayStart,
        today: todayDay,
        completedTasks: completedOnDay,
        focusSeconds: focusSeconds,
        sessionCount: sessionCount,
      );

      return ExecutionTimelineDay(
        weekdayIndex: index,
        label: _dayLabels[index],
        quality: quality,
        completedTasks: completedOnDay,
        focusSeconds: focusSeconds,
        sessionCount: sessionCount,
      );
    });
  }

  static ExecutionDayQuality _qualityForDay({
    required DateTime day,
    required DateTime today,
    required int completedTasks,
    required int focusSeconds,
    required int sessionCount,
  }) {
    if (day.isAfter(today)) {
      return ExecutionDayQuality.review;
    }

    final focusMinutes = focusSeconds / 60;
    final dayScore = (completedTasks * 20).clamp(0, 40) +
        ((focusMinutes / 45) * 40).clamp(0, 40) +
        (sessionCount * 10).clamp(0, 20);

    if (dayScore >= 70) {
      return ExecutionDayQuality.strong;
    }
    if (dayScore >= 35) {
      return ExecutionDayQuality.moderate;
    }
    if (completedTasks == 0 && focusSeconds == 0 && sessionCount == 0) {
      return ExecutionDayQuality.review;
    }
    return ExecutionDayQuality.weak;
  }
}
