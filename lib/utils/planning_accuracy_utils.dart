import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';

/// Done tasks with an estimate and logged focus time — used for calibration counts.
bool taskHasPlanningAccuracyInputs(Task task) {
  return task.status == TaskStatus.done &&
      task.estimatedDurationMinutes != null &&
      task.estimatedDurationMinutes! > 0 &&
      task.totalFocusedSeconds > 0;
}

/// Tasks that have a persisted accuracy score for analytics.
bool taskQualifiesForPlanningAccuracy(Task task) {
  return taskHasPlanningAccuracyInputs(task) && task.planningAccuracy != null;
}

int countQualifyingPlanningAccuracyTasks(Iterable<Task> tasks) {
  return tasks.where(taskQualifiesForPlanningAccuracy).length;
}
