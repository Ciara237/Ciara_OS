import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/repositories/task_repository.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:ciaraos/utils/planning_accuracy_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Marks [task] done, re-reads latest focus totals, and persists planning accuracy.
Future<Task?> markTaskDone(WidgetRef ref, Task task) async {
  final repository = ref.read(taskRepositoryProvider);
  final latest = await repository.getById(task.id) ?? task;
  final done = latest.markedDone();
  await repository.update(done.toCompanion());
  await persistPlanningAccuracyForTask(repository, task.id);
  ref.invalidate(taskByIdProvider(task.id));
  return repository.getById(task.id);
}

Future<void> persistPlanningAccuracyForTask(
  TaskRepository repository,
  int taskId,
) async {
  final task = await repository.getById(taskId);
  if (task == null || task.status != TaskStatus.done) {
    return;
  }

  if (!taskHasPlanningAccuracyInputs(task)) {
    return;
  }

  final accuracy = computePlanningAccuracy(
    estimatedMinutes: task.estimatedDurationMinutes,
    totalFocusedSeconds: task.totalFocusedSeconds,
  );
  if (accuracy == null) {
    return;
  }

  await repository.update(
    task
        .copyWith(
          planningAccuracy: accuracy,
          updatedAt: DateTime.now(),
        )
        .toCompanion(),
  );
}
