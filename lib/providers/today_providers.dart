import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/focus_quality.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/focus_session_record.dart';
import 'package:ciaraos/models/performance_metric_trend.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/daily_stats_providers.dart';
import 'package:ciaraos/providers/focus_session_repository_provider.dart';
import 'package:ciaraos/providers/focus_session_provider.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:ciaraos/utils/task_filter_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final todayDomainFilterProvider = StateProvider<Domain?>((ref) => null);
final todayDeadlineFilterProvider = StateProvider<String?>((ref) => null);
final todayStatusFilterProvider = StateProvider<TaskStatus?>((ref) => null);

final filteredTodayTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(todayTasksProvider);
  final domain = ref.watch(todayDomainFilterProvider);
  final deadline = ref.watch(todayDeadlineFilterProvider);
  final status = ref.watch(todayStatusFilterProvider);

  return tasksAsync.whenData(
    (tasks) => applyTaskFilters(
      tasks: tasks,
      domain: domain,
      deadline: deadline,
      status: status,
      excludeDone: true,
    ),
  );
});

class TodayPerformanceSnapshot {
  const TodayPerformanceSnapshot({
    required this.completedToday,
    required this.totalToday,
    required this.focusSeconds,
    required this.dailyStreak,
    required this.sessionCountToday,
    required this.averageQualityScore,
    required this.planningAccuracy,
    required this.completedTrend,
    required this.focusTrend,
    required this.sessionsTrend,
    required this.qualityTrend,
    required this.accuracyTrend,
    required this.streakTrend,
  });

  final int completedToday;
  final int totalToday;
  final int focusSeconds;
  final int dailyStreak;
  final int sessionCountToday;
  final double? averageQualityScore;
  final double? planningAccuracy;
  final PerformanceMetricTrend completedTrend;
  final PerformanceMetricTrend focusTrend;
  final PerformanceMetricTrend sessionsTrend;
  final PerformanceMetricTrend qualityTrend;
  final PerformanceMetricTrend accuracyTrend;
  final PerformanceMetricTrend streakTrend;

  bool get streakIncreased => streakTrend.isPositive;
}

double? _averageAccuracyForTasks(List<Task> tasks) {
  final values = tasks
      .where((task) => task.planningAccuracy != null)
      .map((task) => task.planningAccuracy!)
      .toList();
  if (values.isEmpty) {
    return null;
  }
  return values.reduce((a, b) => a + b) / values.length;
}

double? _averageQualityForSessions(List<FocusSessionRecord> sessions) {
  final scores = sessions
      .where((session) => session.focusQuality != null)
      .map((session) => focusQualityScore(session.focusQuality!).toDouble())
      .toList();
  if (scores.isEmpty) {
    return null;
  }
  return scores.reduce((a, b) => a + b) / scores.length;
}

final todayPerformanceProvider =
    FutureProvider<TodayPerformanceSnapshot>((ref) async {
  ref.watch(focusSessionProvider);
  ref.watch(dailyStatsRevisionProvider);
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));
  final allTasks = ref.watch(allTasksProvider).value ?? const <Task>[];
  final dayTasks = tasksForPerformanceDay(allTasks, now: now);
  final yesterdayDayTasks = tasksForPerformanceDay(allTasks, now: yesterday);

  final completed =
      allTasks.where((task) => taskCompletedToday(task, now: now)).length;
  final completedYesterday =
      allTasks.where((task) => taskCompletedToday(task, now: yesterday)).length;

  final persistedFocus = await DailyActivityStats.todayFocusSeconds();
  final session = ref.read(focusSessionProvider);
  final sessionFocus = session.isActive
      ? ref.read(focusSessionProvider.notifier).unflushedFocusSeconds
      : 0;
  final focusSeconds = persistedFocus + sessionFocus;
  final yesterdayFocus = await DailyActivityStats.focusSecondsFor(yesterday);

  final focusRepo = ref.read(focusSessionRepositoryProvider);
  final todaySessions = await focusRepo.getCompletedSessionsForDay(now);
  final yesterdaySessions =
      await focusRepo.getCompletedSessionsForDay(yesterday);
  final sessionCountToday =
      todaySessions.length + (session.isActive ? 1 : 0);

  final averageQualityScore = _averageQualityForSessions(todaySessions);
  final yesterdayQualityScore = _averageQualityForSessions(yesterdaySessions);
  final avgAccuracy = _averageAccuracyForTasks(dayTasks);
  final yesterdayAccuracy = _averageAccuracyForTasks(yesterdayDayTasks);

  final streakMeta = await DailyActivityStats.streakSnapshot();
  final dailyStreak = await DailyActivityStats.dailyStreak();
  final yesterdayStreak = streakAtEndOfYesterday(
    currentStreak: streakMeta.streak,
    lastActiveIso: streakMeta.lastActive,
    now: now,
  );

  double? accuracyDelta;
  if (avgAccuracy != null && yesterdayAccuracy != null) {
    accuracyDelta = avgAccuracy - yesterdayAccuracy;
  } else if (avgAccuracy != null && yesterdayAccuracy == null) {
    accuracyDelta = avgAccuracy;
  }

  double? qualityDelta;
  if (averageQualityScore != null && yesterdayQualityScore != null) {
    qualityDelta =
        relativePercentChange(averageQualityScore, yesterdayQualityScore);
  } else if (averageQualityScore != null && yesterdayQualityScore == null) {
    qualityDelta = 100;
  }

  final focusHoursDelta = (focusSeconds - yesterdayFocus) / 3600.0;

  return TodayPerformanceSnapshot(
    completedToday: completed,
    totalToday: dayTasks.length,
    focusSeconds: focusSeconds,
    dailyStreak: dailyStreak,
    sessionCountToday: sessionCountToday,
    averageQualityScore: averageQualityScore,
    planningAccuracy: avgAccuracy,
    completedTrend: PerformanceMetricTrend.fromPercentDelta(
      ratePointChange(
        numeratorToday: completed,
        denominatorToday: dayTasks.length,
        numeratorYesterday: completedYesterday,
        denominatorYesterday: yesterdayDayTasks.length,
      ),
    ),
    focusTrend: PerformanceMetricTrend.fromHoursDelta(focusHoursDelta),
    sessionsTrend: PerformanceMetricTrend.fromAbsoluteDelta(
      sessionCountToday - yesterdaySessions.length,
      unit: '',
      mode: TrendDisplayMode.absolute,
    ),
    qualityTrend: PerformanceMetricTrend.fromPercentDelta(qualityDelta),
    accuracyTrend: PerformanceMetricTrend.fromPercentDelta(accuracyDelta),
    streakTrend: PerformanceMetricTrend.fromAbsoluteDelta(
      dailyStreak - yesterdayStreak,
      unit: 'd',
    ),
  );
});

void clearTodayFilters(WidgetRef ref) {
  ref.read(todayDomainFilterProvider.notifier).state = null;
  ref.read(todayDeadlineFilterProvider.notifier).state = null;
  ref.read(todayStatusFilterProvider.notifier).state = null;
}

bool hasActiveTodayFilters({
  Domain? domain,
  String? deadline,
  TaskStatus? status,
}) {
  return domain != null || deadline != null || status != null;
}
