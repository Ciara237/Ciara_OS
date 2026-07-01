import 'package:ciaraos/models/enums/execution_day_quality.dart';

class ExecutionTimelineDay {
  const ExecutionTimelineDay({
    required this.weekdayIndex,
    required this.label,
    required this.quality,
    required this.completedTasks,
    required this.focusSeconds,
    required this.sessionCount,
  });

  final int weekdayIndex;
  final String label;
  final ExecutionDayQuality quality;
  final int completedTasks;
  final int focusSeconds;
  final int sessionCount;
}
