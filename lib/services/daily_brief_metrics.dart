import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/project_status.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/focus_session_record.dart';
import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/models/weekly_review.dart';

class YesterdaySummary {
  const YesterdaySummary({
    required this.tasksCompleted,
    required this.focusHours,
    required this.sessionCount,
  });

  final int tasksCompleted;
  final double focusHours;
  final int sessionCount;
}

class AbsenceStatus {
  const AbsenceStatus({
    required this.overdueTaskCount,
    required this.activeProjectCount,
    required this.weeklyReviewPending,
    this.mostOverdueTask,
    this.topActiveProject,
  });

  final int overdueTaskCount;
  final int activeProjectCount;
  final bool weeklyReviewPending;
  final Task? mostOverdueTask;
  final Project? topActiveProject;
}

YesterdaySummary computeYesterdaySummary({
  required List<Task> allTasks,
  required List<FocusSessionRecord> sessions,
}) {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  final start = DateTime(yesterday.year, yesterday.month, yesterday.day);
  final end = start.add(const Duration(days: 1));

  final tasksCompleted = allTasks.where((task) {
    if (task.status != TaskStatus.done) {
      return false;
    }
    final updated = task.updatedAt;
    return !updated.isBefore(start) && updated.isBefore(end);
  }).length;

  final focusSeconds = sessions.fold<int>(
    0,
    (sum, session) => sum + session.durationSeconds,
  );

  return YesterdaySummary(
    tasksCompleted: tasksCompleted,
    focusHours: focusSeconds / 3600,
    sessionCount: sessions.length,
  );
}

int countOverdueTasks(List<Task> allTasks) {
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);

  return allTasks.where((task) {
    if (task.status == TaskStatus.done || task.deadline == null) {
      return false;
    }
    final deadline = DateTime(
      task.deadline!.year,
      task.deadline!.month,
      task.deadline!.day,
    );
    return deadline.isBefore(todayStart);
  }).length;
}

Task? mostOverdueTask(List<Task> allTasks) {
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);

  final overdue = allTasks.where((task) {
    if (task.status == TaskStatus.done || task.deadline == null) {
      return false;
    }
    final deadline = DateTime(
      task.deadline!.year,
      task.deadline!.month,
      task.deadline!.day,
    );
    return deadline.isBefore(todayStart);
  }).toList();

  if (overdue.isEmpty) {
    return null;
  }

  overdue.sort((a, b) => a.deadline!.compareTo(b.deadline!));
  return overdue.first;
}

Project? topActiveProject(List<Project> projects) {
  for (final project in projects) {
    if (project.status == ProjectStatus.active) {
      return project;
    }
  }
  return null;
}

bool isWeeklyReviewPending(WeeklyReview? review) {
  if (review == null) {
    return true;
  }
  return !review.locked;
}

AbsenceStatus computeAbsenceStatus({
  required List<Task> allTasks,
  required List<Project> projects,
  required WeeklyReview? weekReview,
}) {
  return AbsenceStatus(
    overdueTaskCount: countOverdueTasks(allTasks),
    activeProjectCount: projects
        .where((project) => project.status == ProjectStatus.active)
        .length,
    weeklyReviewPending: isWeeklyReviewPending(weekReview),
    mostOverdueTask: mostOverdueTask(allTasks),
    topActiveProject: topActiveProject(projects),
  );
}

Task? topPriorityTask(List<Task> tasks) {
  if (tasks.isEmpty) {
    return null;
  }

  const order = {
    Priority.critical: 0,
    Priority.high: 1,
    Priority.medium: 2,
    Priority.low: 3,
  };

  final sorted = [...tasks]
    ..sort(
      (a, b) => order[a.priority]!.compareTo(order[b.priority]!),
    );
  return sorted.first;
}
