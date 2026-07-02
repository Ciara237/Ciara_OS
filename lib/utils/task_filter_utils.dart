import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Deadline filter keys stored in [deadlineFilterProvider].
abstract final class TaskDeadlineFilter {
  static const String today = 'today';
  static const String week = 'week';
  static const String month = 'month';
}

bool hasActiveTaskFilters({
  Domain? domain,
  String? deadline,
  TaskStatus? status,
}) {
  return domain != null || deadline != null || status != null;
}

List<Task> applyTaskFilters({
  required List<Task> tasks,
  Domain? domain,
  String? deadline,
  TaskStatus? status,
  bool excludeDone = false,
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  var filtered = tasks;

  if (domain != null) {
    filtered = filtered.where((task) => task.domain == domain).toList();
  }

  if (status != null) {
    filtered = filtered.where((task) => task.status == status).toList();
  } else if (excludeDone) {
    filtered =
        filtered.where((task) => task.status != TaskStatus.done).toList();
  }

  if (deadline != null) {
    filtered = filtered.where((task) {
      final taskDeadline = task.deadline;
      if (taskDeadline == null) {
        return false;
      }
      return _matchesDeadlineFilter(taskDeadline, deadline, clock);
    }).toList();
  }

  filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return filtered;
}

bool _matchesDeadlineFilter(
  DateTime taskDeadline,
  String filter,
  DateTime now,
) {
  final deadline = DateTime(
    taskDeadline.year,
    taskDeadline.month,
    taskDeadline.day,
  );
  final today = DateTime(now.year, now.month, now.day);

  return switch (filter) {
    TaskDeadlineFilter.today => _isSameDay(deadline, today),
    TaskDeadlineFilter.week => _isInSameWeek(deadline, today),
    TaskDeadlineFilter.month =>
      deadline.year == today.year && deadline.month == today.month,
    _ => true,
  };
}

bool _isSameDay(DateTime a, DateTime b) => isSameCalendarDay(a, b);

bool isSameCalendarDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool taskCompletedToday(Task task, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  return task.status == TaskStatus.done &&
      isSameCalendarDay(task.updatedAt, clock);
}

/// Today's plan plus tasks completed today (even if removed from the today queue).
List<Task> tasksForPerformanceDay(List<Task> allTasks, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  final seen = <int>{};

  return allTasks.where((task) {
    if (!task.today && !taskCompletedToday(task, now: clock)) {
      return false;
    }
    return seen.add(task.id);
  }).toList();
}

bool _isInSameWeek(DateTime date, DateTime anchor) {
  final weekStart = anchor.subtract(Duration(days: anchor.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 6));
  return !date.isBefore(
        DateTime(weekStart.year, weekStart.month, weekStart.day),
      ) &&
      !date.isAfter(DateTime(weekEnd.year, weekEnd.month, weekEnd.day));
}

enum TaskDeadlineDisplay { today, overdue, date, none }

TaskDeadlineDisplay deadlineDisplayFor(Task task, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  final today = DateTime(clock.year, clock.month, clock.day);

  if (task.today) {
    return TaskDeadlineDisplay.today;
  }

  final deadline = task.deadline;
  if (deadline == null) {
    return TaskDeadlineDisplay.none;
  }

  final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
  if (deadlineDay.isBefore(today) && task.status != TaskStatus.done) {
    return TaskDeadlineDisplay.overdue;
  }

  if (_isSameDay(deadlineDay, today)) {
    return TaskDeadlineDisplay.today;
  }

  return TaskDeadlineDisplay.date;
}

void clearAllFilters(WidgetRef ref) {
  ref.read(domainFilterProvider.notifier).state = null;
  ref.read(deadlineFilterProvider.notifier).state = null;
  ref.read(statusFilterProvider.notifier).state = null;
}
