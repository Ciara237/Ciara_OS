import 'package:ciaraos/models/completed_tasks_data.dart';
import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/services/completed_tasks_service.dart';
import 'package:flutter_test/flutter_test.dart';

Task _completedTask({
  required int id,
  required DateTime completedAt,
  int focusedSeconds = 2700,
  int? estimatedMinutes = 45,
  double? planningAccuracy = 94,
  Domain domain = Domain.engineering,
  Priority priority = Priority.medium,
  int? projectId,
}) {
  return Task(
    id: id,
    title: 'Task $id',
    domain: domain,
    status: TaskStatus.done,
    priority: priority,
    started: false,
    today: false,
    projectId: projectId,
    postponeCount: 0,
    estimatedDurationMinutes: estimatedMinutes,
    totalFocusedSeconds: focusedSeconds,
    focusSessionCount: 1,
    planningAccuracy: planningAccuracy,
    createdAt: completedAt.subtract(const Duration(days: 2)),
    updatedAt: completedAt,
  );
}

void main() {
  group('CompletedTasksService', () {
    test('computes stats and groups tasks by day', () {
      final now = DateTime(2026, 7, 2, 15, 0);
      final weekStart = DateTime(2026, 6, 30);
      final tasks = [
        _completedTask(id: 1, completedAt: now),
        _completedTask(id: 2, completedAt: now.subtract(const Duration(hours: 2))),
        _completedTask(
          id: 3,
          completedAt: now.subtract(const Duration(days: 1, hours: 1)),
        ),
        _completedTask(
          id: 4,
          completedAt: weekStart.add(const Duration(hours: 10)),
        ),
        _completedTask(
          id: 5,
          completedAt: weekStart.subtract(const Duration(days: 3)),
        ),
      ];

      final data = CompletedTasksService().compute(
        allTasks: tasks,
        projectNames: const {10: 'Project Alpha'},
        filter: CompletedTasksFilter.all,
        now: now,
      );

      expect(data.stats.totalCompleted, 5);
      expect(data.stats.completedThisWeek, 4);
      expect(data.sections.map((section) => section.label), [
        'Today',
        'Yesterday',
        'Earlier This Week',
      ]);
      expect(data.hasArchive, isTrue);
      expect(data.archiveTaskCount, 1);
      expect(data.weeklyDistribution.length, 7);
    });

    test('filters completed tasks for today', () {
      final now = DateTime(2026, 7, 2, 12);
      final tasks = [
        _completedTask(id: 1, completedAt: now),
        _completedTask(
          id: 2,
          completedAt: now.subtract(const Duration(days: 1)),
        ),
      ];

      final data = CompletedTasksService().compute(
        allTasks: tasks,
        projectNames: const {},
        filter: CompletedTasksFilter.today,
        now: now,
      );

      expect(data.filteredTasks.length, 1);
      expect(data.filteredTasks.first.id, 1);
      expect(data.sections.single.label, 'Today');
    });
  });
}
