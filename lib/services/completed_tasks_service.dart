import 'package:ciaraos/models/completed_tasks_data.dart';
import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/utils/task_filter_utils.dart';
import 'package:ciaraos/utils/planning_accuracy_utils.dart';
import 'package:intl/intl.dart';

class CompletedTasksService {
  static const archiveBatchSize = 20;

  CompletedTasksData compute({
    required List<Task> allTasks,
    required Map<int, String> projectNames,
    required CompletedTasksFilter filter,
    Domain? domainFilter,
    Priority? priorityFilter,
    int? projectFilter,
    int archiveLimit = 0,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final completed = allTasks
        .where((task) => task.status == TaskStatus.done)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final stats = _computeStats(completed, clock);
    final weeklyDistribution = _weeklyDistribution(completed, clock);
    final filtered = _applyFilters(
      completed,
      filter: filter,
      domainFilter: domainFilter,
      priorityFilter: priorityFilter,
      projectFilter: projectFilter,
      now: clock,
    );

    final weekStart = _startOfWeek(clock);
    final today = _startOfDay(clock);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayTasks = <Task>[];
    final yesterdayTasks = <Task>[];
    final earlierThisWeekTasks = <Task>[];
    final archiveTasks = <Task>[];

    for (final task in filtered) {
      final completedDay = _startOfDay(task.updatedAt);
      if (isSameCalendarDay(completedDay, today)) {
        todayTasks.add(task);
      } else if (isSameCalendarDay(completedDay, yesterday)) {
        yesterdayTasks.add(task);
      } else if (!completedDay.isBefore(weekStart)) {
        earlierThisWeekTasks.add(task);
      } else {
        archiveTasks.add(task);
      }
    }

    final sections = <CompletedTaskSection>[
      if (todayTasks.isNotEmpty)
        CompletedTaskSection(label: 'Today', tasks: todayTasks),
      if (yesterdayTasks.isNotEmpty)
        CompletedTaskSection(label: 'Yesterday', tasks: yesterdayTasks),
      if (earlierThisWeekTasks.isNotEmpty)
        CompletedTaskSection(
          label: 'Earlier This Week',
          tasks: earlierThisWeekTasks,
        ),
    ];

    if (archiveLimit > 0 && archiveTasks.isNotEmpty) {
      sections.add(
        CompletedTaskSection(
          label: 'Historical Archive',
          tasks: archiveTasks.take(archiveLimit).toList(),
        ),
      );
    }

    return CompletedTasksData(
      stats: stats,
      weeklyDistribution: weeklyDistribution,
      sections: sections,
      filteredTasks: filtered,
      hasArchive: archiveTasks.isNotEmpty,
      archiveTaskCount: archiveTasks.length,
      availableProjects: _projectOptions(completed, projectNames),
      availableDomains: _availableDomains(completed),
      availablePriorities: _availablePriorities(completed),
    );
  }

  static CompletedTasksStats _computeStats(List<Task> completed, DateTime now) {
    final weekStart = _startOfWeek(now);
    final weekEnd = weekStart.add(const Duration(days: 7));
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));

    final thisWeek = completed.where((task) {
      final day = task.updatedAt;
      return !day.isBefore(weekStart) && day.isBefore(weekEnd);
    }).toList();

    final lastWeek = completed.where((task) {
      final day = task.updatedAt;
      return !day.isBefore(lastWeekStart) && day.isBefore(weekStart);
    }).length;

    final focusedSeconds = thisWeek.fold<int>(
      0,
      (sum, task) => sum + task.totalFocusedSeconds,
    );
    final deepWorkHours = focusedSeconds / 3600;
    final daysElapsed = now.difference(weekStart).inDays + 1;
    final avgPerDay = daysElapsed <= 0 ? 0.0 : deepWorkHours / daysElapsed;

    final accuracyTasks = completed
        .where(taskQualifiesForPlanningAccuracy)
        .toList();
    final avgAccuracy = accuracyTasks.isEmpty
        ? null
        : accuracyTasks.fold<double>(
                0, (sum, task) => sum + task.planningAccuracy!) /
            accuracyTasks.length;

    double? weekChange;
    if (lastWeek > 0) {
      weekChange = ((thisWeek.length - lastWeek) / lastWeek) * 100;
    } else if (thisWeek.isNotEmpty) {
      weekChange = 100;
    }

    final weeklyShare = completed.isEmpty
        ? 0.0
        : (thisWeek.length / completed.length).clamp(0.0, 1.0);

    return CompletedTasksStats(
      totalCompleted: completed.length,
      completedThisWeek: thisWeek.length,
      weekOverWeekChangePercent: weekChange,
      deepWorkHoursThisWeek: deepWorkHours,
      avgDeepWorkHoursPerDay: avgPerDay,
      avgAccuracy: avgAccuracy,
      weeklySharePercent: weeklyShare * 100,
    );
  }

  static List<WeeklyDistributionPoint> _weeklyDistribution(
    List<Task> completed,
    DateTime now,
  ) {
    final weekStart = _startOfWeek(now);
    final formatter = DateFormat('EEE');

    return List.generate(7, (index) {
      final day = weekStart.add(Duration(days: index));
      final nextDay = day.add(const Duration(days: 1));
      final count = completed.where((task) {
        final completedAt = task.updatedAt;
        return !completedAt.isBefore(day) && completedAt.isBefore(nextDay);
      }).length;

      return WeeklyDistributionPoint(
        day: day,
        label: formatter.format(day).toUpperCase(),
        count: count,
      );
    });
  }

  static List<Task> _applyFilters(
    List<Task> completed, {
    required CompletedTasksFilter filter,
    Domain? domainFilter,
    Priority? priorityFilter,
    int? projectFilter,
    required DateTime now,
  }) {
    var filtered = completed;

    switch (filter) {
      case CompletedTasksFilter.today:
        filtered = filtered
            .where((task) => taskCompletedToday(task, now: now))
            .toList();
      case CompletedTasksFilter.domain:
        if (domainFilter != null) {
          filtered =
              filtered.where((task) => task.domain == domainFilter).toList();
        }
      case CompletedTasksFilter.priority:
        if (priorityFilter != null) {
          filtered =
              filtered.where((task) => task.priority == priorityFilter).toList();
        }
      case CompletedTasksFilter.project:
        if (projectFilter != null) {
          filtered = filtered
              .where((task) => task.projectId == projectFilter)
              .toList();
        }
      case CompletedTasksFilter.all:
        break;
    }

    return filtered;
  }

  static List<CompletedProjectOption> _projectOptions(
    List<Task> completed,
    Map<int, String> projectNames,
  ) {
    final ids = <int>{};
    final options = <CompletedProjectOption>[];

    for (final task in completed) {
      final projectId = task.projectId;
      if (projectId == null || !ids.add(projectId)) {
        continue;
      }
      final name = projectNames[projectId];
      if (name == null) {
        continue;
      }
      options.add(CompletedProjectOption(id: projectId, name: name));
    }

    options.sort((a, b) => a.name.compareTo(b.name));
    return options;
  }

  static List<Domain> _availableDomains(List<Task> completed) {
    final domains = completed.map((task) => task.domain).toSet().toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    return domains;
  }

  static List<Priority> _availablePriorities(List<Task> completed) {
    const order = [
      Priority.critical,
      Priority.high,
      Priority.medium,
      Priority.low,
    ];
    final present = completed.map((task) => task.priority).toSet();
    return order.where(present.contains).toList();
  }

  static DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime _startOfWeek(DateTime date) {
    final day = _startOfDay(date);
    return day.subtract(Duration(days: day.weekday - 1));
  }
}
