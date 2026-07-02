import 'package:ciaraos/models/enums/project_status.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/opportunity.dart';
import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/task.dart';
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

    final weekCompleted =
        weekTasks.where((task) => task.status == TaskStatus.done).length;
    final totalFocusSeconds = weekTasks.fold<int>(
      0,
      (sum, task) => sum + task.totalFocusedSeconds,
    );

    Task? mostPostponed;
    for (final task in allTasks) {
      if (mostPostponed == null ||
          task.postponeCount > mostPostponed.postponeCount) {
        mostPostponed = task;
      }
    }

    return {
      'date': DateFormat('yyyy-MM-dd').format(now),
      'tasks_today': todayTasks.map(_taskToJson).toList(),
      'this_week': {
        'started_rate': weekTasks.isEmpty
            ? 0.0
            : weekTasks.where((task) => task.started).length / weekTasks.length,
        'tasks_completed': weekCompleted,
        'tasks_total': weekTasks.length,
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
