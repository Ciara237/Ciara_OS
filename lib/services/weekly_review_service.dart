import 'package:ciaraos/models/enums/focus_quality.dart';
import 'package:ciaraos/models/enums/project_status.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/focus_session_record.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/models/weekly_debrief.dart';
import 'package:ciaraos/models/weekly_execution_metrics.dart';
import 'package:ciaraos/repositories/focus_session_repository.dart';
import 'package:ciaraos/repositories/project_repository.dart';
import 'package:ciaraos/repositories/task_repository.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:ciaraos/services/execution_score_calculator.dart';
import 'package:ciaraos/services/execution_timeline_generator.dart';
import 'package:ciaraos/services/insight_generator.dart';
import 'package:ciaraos/services/weekly_narrative_generator.dart';

/// Orchestrates Executive Debrief data for the review screen.
class WeeklyReviewService {
  WeeklyReviewService({
    required TaskRepository taskRepository,
    required FocusSessionRepository focusSessionRepository,
    required ProjectRepository projectRepository,
  })  : _taskRepository = taskRepository,
        _focusSessionRepository = focusSessionRepository,
        _projectRepository = projectRepository;

  final TaskRepository _taskRepository;
  final FocusSessionRepository _focusSessionRepository;
  final ProjectRepository _projectRepository;

  Future<WeeklyDebrief> buildDebrief(DateTime weekMonday) async {
    final monday = DateTime(
      weekMonday.year,
      weekMonday.month,
      weekMonday.day,
    );
    final previousMonday = monday.subtract(const Duration(days: 7));

    final completedTasks =
        await _taskRepository.getTasksCompletedInWeek(monday);
    final weekTasks = await _taskRepository.getTasksForWeek(monday);
    final sessions =
        await _focusSessionRepository.getCompletedSessionsForWeek(monday);
    final dailyFocusSeconds = await DailyActivityStats.focusSecondsForWeek(monday);
    final streak = await DailyActivityStats.dailyStreak();

    final tasksInScope = {
      ...weekTasks.map((task) => task.id),
      ...completedTasks.map((task) => task.id),
    }.length;

    final sessionFocusSeconds =
        sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    final persistedFocus =
        dailyFocusSeconds.fold<int>(0, (sum, seconds) => sum + seconds);
    final deepWorkSeconds = sessionFocusSeconds > persistedFocus
        ? sessionFocusSeconds
        : persistedFocus;

    final accuracyValues = completedTasks
        .where((task) => task.planningAccuracy != null)
        .map((task) => task.planningAccuracy!)
        .toList();
    final planningAccuracy = accuracyValues.isEmpty
        ? null
        : accuracyValues.reduce((a, b) => a + b) / accuracyValues.length;

    final qualityScores = sessions
        .where((session) => session.focusQuality != null)
        .map((session) => focusQualityScore(session.focusQuality!).toDouble())
        .toList();
    final averageFocusQuality = qualityScores.isEmpty
        ? null
        : qualityScores.reduce((a, b) => a + b) / qualityScores.length;

    final biggestWin = _resolveBiggestWin(completedTasks, sessions);

    final timeline = ExecutionTimelineGenerator.generate(
      weekMonday: monday,
      completedTasks: completedTasks,
      dailyFocusSeconds: dailyFocusSeconds,
      sessions: sessions,
    );

    final contextSwitchDays = timeline
        .where((day) => day.sessionCount >= 3)
        .length;

    final metrics = WeeklyExecutionMetrics(
      weekOf: monday,
      tasksCompleted: completedTasks.length,
      tasksInScope: tasksInScope,
      deepWorkSeconds: deepWorkSeconds,
      focusSessionCount: sessions.length,
      planningAccuracy: planningAccuracy,
      longestStreak: streak,
      biggestWin: biggestWin,
      averageFocusQuality: averageFocusQuality,
      dailyFocusSeconds: dailyFocusSeconds,
      timeline: timeline,
      completedTasks: completedTasks,
      sessionsThisWeek: sessions.length,
      contextSwitchDays: contextSwitchDays,
    );

    final scoreResult = ExecutionScoreCalculator.calculate(metrics);
    final previousDebrief = await _loadPriorWeekScore(previousMonday);
    final scoreDelta = previousDebrief == null
        ? null
        : scoreResult.score - previousDebrief.score;
    final hasPriorWeekData = previousDebrief != null &&
        (previousDebrief.metrics.tasksCompleted > 0 ||
            previousDebrief.metrics.focusSessionCount > 0);

    final insights = InsightGenerator.generate(
      metrics: metrics,
      scoreDelta: scoreDelta,
      sessions: sessions,
    );

    final narrative = WeeklyNarrativeGenerator.generate(
      metrics: metrics,
      executionScore: scoreResult.score,
      insights: insights,
    );

    final suggestedPriorities = await suggestPriorities();

    return WeeklyDebrief(
      metrics: metrics,
      executionScore: scoreResult.score,
      scoreDelta: scoreDelta,
      hasPriorWeekData: hasPriorWeekData,
      insights: insights,
      narrative: narrative,
      suggestedPriorities: suggestedPriorities,
    );
  }

  Future<_PriorWeekScore?> _loadPriorWeekScore(DateTime weekMonday) async {
    final monday = DateTime(
      weekMonday.year,
      weekMonday.month,
      weekMonday.day,
    );

    final completedTasks =
        await _taskRepository.getTasksCompletedInWeek(monday);
    if (completedTasks.isEmpty) {
      final sessions =
          await _focusSessionRepository.getCompletedSessionsForWeek(monday);
      if (sessions.isEmpty) {
        return null;
      }
    }

    final weekTasks = await _taskRepository.getTasksForWeek(monday);
    final sessions =
        await _focusSessionRepository.getCompletedSessionsForWeek(monday);
    final dailyFocusSeconds = await DailyActivityStats.focusSecondsForWeek(monday);
    final streak = await DailyActivityStats.dailyStreak();

    final tasksInScope = {
      ...weekTasks.map((task) => task.id),
      ...completedTasks.map((task) => task.id),
    }.length;

    final sessionFocusSeconds =
        sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    final persistedFocus =
        dailyFocusSeconds.fold<int>(0, (sum, seconds) => sum + seconds);

    final accuracyValues = completedTasks
        .where((task) => task.planningAccuracy != null)
        .map((task) => task.planningAccuracy!)
        .toList();

    final qualityScores = sessions
        .where((session) => session.focusQuality != null)
        .map((session) => focusQualityScore(session.focusQuality!).toDouble())
        .toList();

    final metrics = WeeklyExecutionMetrics(
      weekOf: monday,
      tasksCompleted: completedTasks.length,
      tasksInScope: tasksInScope,
      deepWorkSeconds: sessionFocusSeconds > persistedFocus
          ? sessionFocusSeconds
          : persistedFocus,
      focusSessionCount: sessions.length,
      planningAccuracy: accuracyValues.isEmpty
          ? null
          : accuracyValues.reduce((a, b) => a + b) / accuracyValues.length,
      longestStreak: streak,
      biggestWin: _resolveBiggestWin(completedTasks, sessions),
      averageFocusQuality: qualityScores.isEmpty
          ? null
          : qualityScores.reduce((a, b) => a + b) / qualityScores.length,
      dailyFocusSeconds: dailyFocusSeconds,
      timeline: ExecutionTimelineGenerator.generate(
        weekMonday: monday,
        completedTasks: completedTasks,
        dailyFocusSeconds: dailyFocusSeconds,
        sessions: sessions,
      ),
      completedTasks: completedTasks,
      sessionsThisWeek: sessions.length,
      contextSwitchDays: 0,
    );

    return _PriorWeekScore(
      metrics: metrics,
      score: ExecutionScoreCalculator.calculate(metrics).score,
    );
  }

  Future<List<SuggestedPriority>> suggestPriorities() async {
    final suggestions = <SuggestedPriority>[];
    final seen = <String>{};

    void add(String title, {String? domainName}) {
      final normalized = title.trim().toLowerCase();
      if (title.trim().isEmpty || seen.contains(normalized)) {
        return;
      }
      seen.add(normalized);
      suggestions.add(
        SuggestedPriority(title: title.trim(), domainName: domainName),
      );
    }

    final incomplete = await _taskRepository.getIncompleteTasks();
    for (final task in incomplete) {
      if (task.today || task.priority.name == 'high' || task.priority.name == 'critical') {
        add(task.title, domainName: task.domain.name);
      }
      if (suggestions.length >= 5) {
        return suggestions;
      }
    }

    for (final task in incomplete) {
      if (task.status == TaskStatus.inProgress || task.status == TaskStatus.stuck) {
        add(task.title, domainName: task.domain.name);
      }
      if (suggestions.length >= 5) {
        return suggestions;
      }
    }

    final projects = await _projectRepository.watchAll().first;
    for (final project in projects) {
      if (project.status != ProjectStatus.active &&
          project.status != ProjectStatus.paused) {
        continue;
      }
      final next = project.nextAction?.trim();
      if (next != null && next.isNotEmpty) {
        add(next, domainName: project.domain.name);
      }
      if (suggestions.length >= 5) {
        return suggestions;
      }
    }

    for (final task in incomplete) {
      add(task.title, domainName: task.domain.name);
      if (suggestions.length >= 5) {
        break;
      }
    }

    return suggestions;
  }

  String? _resolveBiggestWin(
    List<Task> completedTasks,
    List<FocusSessionRecord> sessions,
  ) {
    if (completedTasks.isEmpty) {
      return null;
    }

    completedTasks.sort(
      (a, b) => b.totalFocusedSeconds.compareTo(a.totalFocusedSeconds),
    );
    return completedTasks.first.title;
  }
}

class _PriorWeekScore {
  const _PriorWeekScore({required this.metrics, required this.score});

  final WeeklyExecutionMetrics metrics;
  final double score;
}
