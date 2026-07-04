import 'dart:async';

import 'package:ciaraos/models/enums/focus_quality.dart';
import 'package:ciaraos/models/focus_session_record.dart';
import 'package:ciaraos/providers/daily_stats_providers.dart';
import 'package:ciaraos/providers/focus_session_repository_provider.dart';
import 'package:ciaraos/repositories/focus_session_repository.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:ciaraos/services/task_completion_service.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live deep work engine state — always bound to a task when active.
class ActiveDeepWorkState {
  const ActiveDeepWorkState({
    this.session,
    this.goalCelebrated = false,
  });

  final FocusSessionRecord? session;
  final bool goalCelebrated;

  bool get isActive => session != null;

  bool get isRunning => session?.isRunning ?? false;

  int? get taskId => session?.taskId;

  int get totalElapsedSeconds => session?.liveElapsedSeconds ?? 0;

  double get goalProgress =>
      (totalElapsedSeconds / deepWorkGoalSeconds).clamp(0.0, 1.0);

  bool get goalReached => totalElapsedSeconds >= deepWorkGoalSeconds;

  int get remainingToGoal =>
      (deepWorkGoalSeconds - totalElapsedSeconds).clamp(0, deepWorkGoalSeconds);

  bool isTrackingTask(int id) => session?.taskId == id;

  ActiveDeepWorkState copyWith({
    FocusSessionRecord? session,
    bool? goalCelebrated,
    bool clearSession = false,
  }) {
    return ActiveDeepWorkState(
      session: clearSession ? null : (session ?? this.session),
      goalCelebrated: goalCelebrated ?? this.goalCelebrated,
    );
  }
}

class DeepWorkEngineNotifier extends Notifier<ActiveDeepWorkState> {
  Timer? _ticker;
  int _dailyFlushedSeconds = 0;
  bool _initialized = false;

  @override
  ActiveDeepWorkState build() {
    ref.onDispose(_stopTicker);
    if (!_initialized) {
      _initialized = true;
      Future.microtask(_hydrateFromDatabase);
    }
    return const ActiveDeepWorkState();
  }

  FocusSessionRepository get _repo => ref.read(focusSessionRepositoryProvider);

  int get unflushedFocusSeconds {
    if (!state.isActive) {
      return 0;
    }
    return state.totalElapsedSeconds - _dailyFlushedSeconds;
  }

  Future<void> _hydrateFromDatabase() async {
    final active = await _repo.getActiveSession();
    if (active == null) {
      return;
    }
    state = ActiveDeepWorkState(
      session: active,
      goalCelebrated: active.liveElapsedSeconds >= deepWorkGoalSeconds,
    );
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _startTicker() {
    _stopTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      final current = state.session;
      if (current == null || !current.isRunning) {
        return;
      }

      final elapsed = current.liveElapsedSeconds;
      if (elapsed >= deepWorkGoalSeconds && !state.goalCelebrated) {
        state = state.copyWith(goalCelebrated: true);
      }

      state = ActiveDeepWorkState(
        session: current,
        goalCelebrated: state.goalCelebrated,
      );

      if (elapsed % 15 == 0) {
        final persisted = await _repo.persistProgress(current);
        state = ActiveDeepWorkState(
          session: persisted,
          goalCelebrated: state.goalCelebrated,
        );
      }
    });
  }

  Future<void> _flushToDaily() async {
    final delta = unflushedFocusSeconds;
    if (delta <= 0) {
      return;
    }
    await DailyActivityStats.addFocusSeconds(delta);
    await DailyActivityStats.recordActiveDay();
    _dailyFlushedSeconds = state.totalElapsedSeconds;
    ref.read(dailyStatsRevisionProvider.notifier).state++;
  }

  Future<void> startForTask(int taskId) async {
    final current = state.session;
    if (current?.taskId == taskId && current!.isRunning) {
      return;
    }
    if (current?.taskId == taskId && !current!.isRunning) {
      await resume();
      return;
    }

    if (state.isActive) {
      await _flushToDaily();
    }

    _dailyFlushedSeconds = 0;
    final session = await _repo.startSession(taskId);
    state = ActiveDeepWorkState(session: session);
    _startTicker();

    final task = await ref.read(taskRepositoryProvider).getById(taskId);
    if (task != null && !task.started) {
      await ref.read(taskRepositoryProvider).update(
            task
                .copyWith(started: true, updatedAt: DateTime.now())
                .toCompanion(),
          );
      ref.invalidate(taskByIdProvider(taskId));
    }
  }

  Future<void> pause() async {
    final session = state.session;
    if (session == null || !session.isRunning) {
      return;
    }

    final paused = await _repo.pauseSession(session);
    await _flushToDaily();
    _stopTicker();
    state = ActiveDeepWorkState(
      session: paused,
      goalCelebrated: state.goalCelebrated,
    );

    final task = await ref.read(taskRepositoryProvider).getById(session.taskId);
    if (task != null && task.started) {
      await ref.read(taskRepositoryProvider).update(
            task
                .copyWith(started: false, updatedAt: DateTime.now())
                .toCompanion(),
          );
      ref.invalidate(taskByIdProvider(session.taskId));
    }
  }

  Future<void> resume() async {
    final session = state.session;
    if (session == null || session.isRunning) {
      return;
    }

    final resumed = await _repo.resumeSession(session);
    state = ActiveDeepWorkState(
      session: resumed,
      goalCelebrated: state.goalCelebrated,
    );
    _startTicker();

    final task = await ref.read(taskRepositoryProvider).getById(session.taskId);
    if (task != null && !task.started) {
      await ref.read(taskRepositoryProvider).update(
            task
                .copyWith(started: true, updatedAt: DateTime.now())
                .toCompanion(),
          );
      ref.invalidate(taskByIdProvider(session.taskId));
    }
  }

  Future<void> endSession(FocusQuality quality) async {
    final session = state.session;
    if (session == null) {
      return;
    }

    await _flushToDaily();
    _stopTicker();
    await _repo.completeSession(
      session: session,
      quality: quality,
      taskRepo: ref.read(taskRepositoryProvider),
    );
    _dailyFlushedSeconds = 0;
    state = const ActiveDeepWorkState();
    ref.read(dailyStatsRevisionProvider.notifier).state++;
    ref.invalidate(taskByIdProvider(session.taskId));
  }

  Future<void> discardActiveSession() async {
    final session = state.session;
    if (session == null) {
      return;
    }

    await _flushToDaily();
    _stopTicker();
    await _repo.discardSession(session);
    _dailyFlushedSeconds = 0;
    state = const ActiveDeepWorkState();

    final task = await ref.read(taskRepositoryProvider).getById(session.taskId);
    if (task != null && task.started) {
      await ref.read(taskRepositoryProvider).update(
            task
                .copyWith(started: false, updatedAt: DateTime.now())
                .toCompanion(),
          );
      ref.invalidate(taskByIdProvider(session.taskId));
    }
  }

  Future<void> recoverSession() async {
    if (state.session == null) {
      await _hydrateFromDatabase();
    }
    final session = state.session;
    if (session == null) {
      return;
    }
    if (session.isRunning) {
      _startTicker();
    } else {
      await resume();
    }
  }

  /// Called when marking task complete — computes planning accuracy.
  Future<void> applyPlanningAccuracyOnComplete(int taskId) async {
    await persistPlanningAccuracyForTask(
      ref.read(taskRepositoryProvider),
      taskId,
    );
    ref.invalidate(taskByIdProvider(taskId));
  }

  void clear() {
    discardActiveSession();
  }
}

/// Deep Work Engine — task-bound focus sessions (replaces standalone timer).
final focusSessionProvider =
    NotifierProvider<DeepWorkEngineNotifier, ActiveDeepWorkState>(
  DeepWorkEngineNotifier.new,
);

/// Whether an interrupted session awaits user recovery choice.
final pendingSessionRecoveryProvider = FutureProvider<bool>((ref) async {
  final session =
      await ref.read(focusSessionRepositoryProvider).getActiveSession();
  return session != null;
});
