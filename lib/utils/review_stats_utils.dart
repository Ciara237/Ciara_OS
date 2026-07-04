import 'package:ciaraos/models/task.dart';
import 'package:intl/intl.dart';

DateTime mondayOfWeek(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  return local.subtract(Duration(days: local.weekday - DateTime.monday));
}

/// ISO week number for review and analytics headers (e.g. Week 27).
int isoWeekNumber(DateTime date) {
  final thursday = date.add(Duration(days: 4 - date.weekday));
  final yearStart = DateTime(thursday.year, 1, 1);
  return 1 + (thursday.difference(yearStart).inDays / 7).floor();
}

/// Human-readable Mon–Sun range, e.g. "June 29 – July 5, 2026".
String reviewWeekRangeLabel(DateTime weekMonday) {
  final end = weekMonday.add(const Duration(days: 6));
  final monthDay = DateFormat('MMMM d');
  final year = DateFormat('y');
  return '${monthDay.format(weekMonday)} – ${monthDay.format(end)}, ${year.format(end)}';
}

/// Full review header week line, e.g. "Week 27 Review".
String reviewWeekTitleLabel(DateTime weekMonday) {
  return 'Week ${isoWeekNumber(weekMonday)} Review';
}

/// Full review header week line, e.g. "Week 27 • June 29 – July 5, 2026".
String reviewWeekHeaderLabel(DateTime weekMonday) {
  return 'Week ${isoWeekNumber(weekMonday)} • ${reviewWeekRangeLabel(weekMonday)}';
}

double startedRateForTasks(List<Task> tasks) {
  if (tasks.isEmpty) {
    return 0;
  }
  return tasks.where((task) => task.started).length / tasks.length;
}

List<double> dailyStartedRates(List<Task> tasks, DateTime weekMonday) {
  return List.generate(7, (index) {
    final day = weekMonday.add(Duration(days: index));
    final dayTasks = tasks.where((task) {
      final created = DateTime(
        task.createdAt.year,
        task.createdAt.month,
        task.createdAt.day,
      );
      return created == day;
    }).toList();
    return startedRateForTasks(dayTasks);
  });
}

int todayWeekdayIndex(DateTime weekMonday) {
  final today = DateTime.now();
  final monday = DateTime(weekMonday.year, weekMonday.month, weekMonday.day);
  final localToday = DateTime(today.year, today.month, today.day);
  return localToday.difference(monday).inDays.clamp(0, 6);
}

String insightForDelta(double? deltaPercent) {
  if (deltaPercent == null) {
    return 'Complete your first week to see trends.';
  }
  if (deltaPercent > 0) {
    return 'Your started-rate improved this week.';
  }
  if (deltaPercent < 0) {
    return 'Started-rate dropped this week. Review what got in the way.';
  }
  return 'Your started-rate held steady this week.';
}

String advisoryForStartedRate(double? startedRate) {
  if (startedRate == null) {
    return 'Complete tasks this week to receive an advisory.';
  }
  if (startedRate < 0.5) {
    return 'Your started-rate this week was below 50%. Consider reducing your daily task count.';
  }
  if (startedRate < 0.8) {
    return 'Solid week. Focus on converting more queued tasks to started.';
  }
  return 'High execution week. Maintain this output and watch for burnout signals.';
}
