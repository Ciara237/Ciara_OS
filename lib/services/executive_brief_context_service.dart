import 'package:ciaraos/models/calendar_event.dart';
import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/utils/task_filter_utils.dart';
import 'package:intl/intl.dart';

enum SchedulePace { ahead, onTrack, behind }

class ExecutiveBriefDayContext {
  const ExecutiveBriefDayContext({
    required this.completedCount,
    required this.totalCount,
    required this.pace,
    required this.statusMessage,
    required this.remainingTasks,
    this.nextEventLabel,
  });

  final int completedCount;
  final int totalCount;
  final SchedulePace pace;
  final String statusMessage;
  final List<Task> remainingTasks;
  final String? nextEventLabel;

  double get progress =>
      totalCount == 0 ? 0 : (completedCount / totalCount).clamp(0.0, 1.0);
}

class ExecutiveBriefContextService {
  ExecutiveBriefDayContext build({
    required List<Task> allTasks,
    List<CalendarEvent> calendarEvents = const [],
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final dayTasks = tasksForPerformanceDay(allTasks, now: clock);
    final completed =
        dayTasks.where((task) => taskCompletedToday(task, now: clock)).length;
    final remaining = dayTasks
        .where((task) => task.status != TaskStatus.done)
        .toList();
    final pace = _schedulePace(
      completed: completed,
      total: dayTasks.length,
      now: clock,
    );
    final nextEvent = _nextUpcomingEvent(calendarEvents, clock);

    return ExecutiveBriefDayContext(
      completedCount: completed,
      totalCount: dayTasks.length,
      pace: pace,
      statusMessage: _statusMessage(
        pace: pace,
        remaining: remaining,
        nextEvent: nextEvent,
        now: clock,
      ),
      remainingTasks: remaining,
      nextEventLabel: nextEvent == null ? null : _eventLabel(nextEvent),
    );
  }

  SchedulePace _schedulePace({
    required int completed,
    required int total,
    required DateTime now,
  }) {
    if (total == 0) {
      return SchedulePace.onTrack;
    }

    const workStartHour = 8;
    const workEndHour = 18;
    final hour = now.hour + (now.minute / 60);
    final expectedFraction = hour <= workStartHour
        ? 0.0
        : hour >= workEndHour
            ? 1.0
            : (hour - workStartHour) / (workEndHour - workStartHour);

    final actualFraction = completed / total;
    final delta = actualFraction - expectedFraction;

    if (delta > 0.12) {
      return SchedulePace.ahead;
    }
    if (delta < -0.12) {
      return SchedulePace.behind;
    }
    return SchedulePace.onTrack;
  }

  String _statusMessage({
    required SchedulePace pace,
    required List<Task> remaining,
    required CalendarEvent? nextEvent,
    required DateTime now,
  }) {
    final paceLabel = switch (pace) {
      SchedulePace.ahead => 'ahead of schedule',
      SchedulePace.onTrack => 'on track',
      SchedulePace.behind => 'behind schedule',
    };

    if (remaining.isEmpty) {
      return 'You are currently **$paceLabel**. All planned tasks for today are complete.';
    }

    final highPriority = remaining
        .where(
          (task) =>
              task.priority == Priority.high ||
              task.priority == Priority.critical,
        )
        .toList();
    final focusTasks = highPriority.isNotEmpty ? highPriority : remaining;
    final domain = _dominantDomain(focusTasks);
    final domainName = domain == null ? 'priority' : domain.name;
    final block = _timeBlockLabel(now);
    final count = focusTasks.length;
    final priorityPrefix =
        highPriority.isNotEmpty ? 'high-priority ' : '';

    final buffer = StringBuffer(
      'You are currently **$paceLabel**. '
      '$count $priorityPrefix$domainName '
      'task${count == 1 ? '' : 's'} remain for the $block block',
    );

    if (nextEvent != null) {
      buffer.write(' before the ${_eventLabel(nextEvent)}');
    }
    buffer.write('.');

    return buffer.toString();
  }

  Domain? _dominantDomain(List<Task> tasks) {
    if (tasks.isEmpty) {
      return null;
    }

    final counts = <Domain, int>{};
    for (final task in tasks) {
      counts[task.domain] = (counts[task.domain] ?? 0) + 1;
    }

    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _timeBlockLabel(DateTime now) {
    final hour = now.hour;
    if (hour < 12) {
      return 'morning';
    }
    if (hour < 17) {
      return 'afternoon';
    }
    return 'evening';
  }

  CalendarEvent? _nextUpcomingEvent(
    List<CalendarEvent> events,
    DateTime now,
  ) {
    final upcoming = events
        .where(
          (event) =>
              !event.isFocusBlock &&
              !event.isAllDay &&
              event.start.isAfter(now),
        )
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    return upcoming.isEmpty ? null : upcoming.first;
  }

  String _eventLabel(CalendarEvent event) {
    final time = DateFormat('h a').format(event.start);
    final title = event.displayTitle.trim();
    if (title.isEmpty) {
      return time.toLowerCase();
    }
    return '$time ${title.toLowerCase()}';
  }
}
