import 'package:ciaraos/models/task.dart';

enum DailyBriefState {
  dailyBrief,
  resumeSession,
  emptyDay,
  returningAfterAbsence,
}

class DailyBriefStateService {
  DailyBriefState compute({
    required List<Task> todayTasks,
    required bool hasInterruptedSession,
    required DateTime? lastOpenedAt,
  }) {
    if (hasInterruptedSession) {
      return DailyBriefState.resumeSession;
    }

    if (lastOpenedAt != null) {
      final hoursSinceOpen =
          DateTime.now().difference(lastOpenedAt).inHours;
      if (hoursSinceOpen > 48) {
        return DailyBriefState.returningAfterAbsence;
      }
    }

    if (todayTasks.isEmpty) {
      return DailyBriefState.emptyDay;
    }

    return DailyBriefState.dailyBrief;
  }
}
