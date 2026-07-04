import 'package:ciaraos/models/enums/project_status.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/opportunity.dart';
import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/utils/review_stats_utils.dart';
import 'package:intl/intl.dart';

class AiContextBuilder {
  Map<String, dynamic> build({
    required List<Task> todayTasks,
    required List<Task> weekTasks,
    required List<Project> projects,
    required List<Opportunity> opportunities,
    required List<Task> allTasks,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekHorizon = today.add(const Duration(days: 7));

    final opportunitiesDue = opportunities.where((opportunity) {
      final deadline = opportunity.deadline;
      if (deadline == null) {
        return false;
      }
      final due = DateTime(deadline.year, deadline.month, deadline.day);
      return !due.isBefore(today) && !due.isAfter(weekHorizon);
    });

    final activeProjects = projects
        .where((project) => project.status == ProjectStatus.active)
        .map((project) {
      final pending = allTasks
          .where(
            (task) =>
                task.projectId == project.id &&
                task.status != TaskStatus.done,
          )
          .length;

      return {
        'name': project.name,
        'next_action': project.nextAction,
        'linked_tasks_pending': pending,
      };
    });

    final weekMonday = mondayOfWeek(now);
    final weekEnd = weekMonday.add(const Duration(days: 7));

    final weekCompleted = allTasks.where((task) {
      if (task.status != TaskStatus.done) {
        return false;
      }
      final updated = DateTime(
        task.updatedAt.year,
        task.updatedAt.month,
        task.updatedAt.day,
      );
      return !updated.isBefore(weekMonday) && updated.isBefore(weekEnd);
    });

    final weekScope = _weekScopeTasks(
      weekTasks: weekTasks,
      weekCompleted: weekCompleted.toList(),
    );

    final totalFocusSeconds = weekScope.fold<int>(
      0,
      (sum, task) => sum + task.totalFocusedSeconds,
    );

    Task? mostPostponed;
    for (final task in allTasks) {
      if (task.status == TaskStatus.done) {
        continue;
      }
      if (mostPostponed == null ||
          task.postponeCount > mostPostponed.postponeCount) {
        mostPostponed = task;
      }
    }

    return {
      'date': DateFormat('yyyy-MM-dd').format(now),
      'tasks_today': todayTasks
          .where((task) => task.status != TaskStatus.done)
          .map(_taskToJson)
          .toList(),
      'this_week': {
        'started_rate': startedRateForTasks(weekScope),
        'tasks_completed': weekCompleted.length,
        'tasks_total': weekScope.length,
        'total_focused_hours': totalFocusSeconds / 3600.0,
      },
      'active_projects': activeProjects.toList(),
      'opportunities_due_this_week': opportunitiesDue
          .map(
            (opportunity) => {
              'title': opportunity.title,
              'organization': opportunity.organization,
              'documents_ready': opportunity.documentsReady,
              'documents_total': opportunity.documentsTotal,
            },
          )
          .toList(),
      'patterns': {
        'most_postponed_task':
            mostPostponed != null && mostPostponed.postponeCount > 0
                ? mostPostponed.title
                : null,
        'most_postponed_count': mostPostponed?.postponeCount ?? 0,
      },
    };
  }

  /// Tasks created or completed this week — same scope as weekly review metrics.
  List<Task> _weekScopeTasks({
    required List<Task> weekTasks,
    required List<Task> weekCompleted,
  }) {
    final byId = <int, Task>{};
    for (final task in weekTasks) {
      byId[task.id] = task;
    }
    for (final task in weekCompleted) {
      byId[task.id] = task;
    }
    return byId.values.toList();
  }

  Map<String, dynamic> _taskToJson(Task task) => {
        'id': task.id.toString(),
        'title': task.title,
        'domain': task.domain.name,
        'priority': task.priority.name,
        'status': task.status.name,
        'started': task.started,
        'postpone_count': task.postponeCount,
        'estimated_duration_minutes': task.estimatedDurationMinutes,
        'total_focused_seconds': task.totalFocusedSeconds,
      };
}
