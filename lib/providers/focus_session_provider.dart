import 'dart:async';

import 'package:ciaraos/providers/daily_stats_providers.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory focus timer for the currently tracked task.
class FocusSession {
  const FocusSession({
    this.taskId,
    this.elapsedSeconds = 0,
    this.segmentStartedAt,
  });

  final int? taskId;
  final int elapsedSeconds;
  final DateTime? segmentStartedAt;

  bool get isActive => taskId != null;

  bool get isRunning => segmentStartedAt != null;

  int get totalElapsedSeconds {
    if (segmentStartedAt == null) {
      return elapsedSeconds;
    }
    return elapsedSeconds +
        DateTime.now().difference(segmentStartedAt!).inSeconds;
  }

  bool isTrackingTask(int id) => taskId == id;

  FocusSession copyWith({
    int? taskId,
    int? elapsedSeconds,
    DateTime? segmentStartedAt,
    bool clearTaskId = false,
    bool clearSegmentStartedAt = false,
  }) {
    return FocusSession(
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      segmentStartedAt: clearSegmentStartedAt
          ? null
          : (segmentStartedAt ?? this.segmentStartedAt),
    );
  }
}

class FocusSessionNotifier extends Notifier<FocusSession> {
  Timer? _ticker;
  int _dailyFlushedSeconds = 0;

  /// Elapsed seconds in the active session not yet written to daily stats.
  int get unflushedFocusSeconds {
    if (!state.isActive) {
      return 0;
    }
    return state.totalElapsedSeconds - _dailyFlushedSeconds;
  }

  @override
  FocusSession build() {
    ref.onDispose(_stopTicker);
    return const FocusSession();
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _startTicker() {
    _stopTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (!current.isRunning) {
        return;
      }
      state = FocusSession(
        taskId: current.taskId,
        elapsedSeconds: current.elapsedSeconds,
        segmentStartedAt: current.segmentStartedAt,
      );
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

  void startForTask(int taskId) {
    if (state.taskId == taskId && state.isRunning) {
      return;
    }

    if (state.taskId == taskId && !state.isRunning) {
      resume();
      return;
    }

    if (state.isActive) {
      _flushToDaily();
    }

    _dailyFlushedSeconds = 0;
    state = FocusSession(
      taskId: taskId,
      elapsedSeconds: 0,
      segmentStartedAt: DateTime.now(),
    );
    _startTicker();
  }

  void pause() {
    if (!state.isActive || !state.isRunning) {
      return;
    }

    final total = state.totalElapsedSeconds;
    _flushToDaily();
    state = FocusSession(
      taskId: state.taskId,
      elapsedSeconds: total,
    );
    _stopTicker();
  }

  void resume() {
    if (!state.isActive || state.isRunning) {
      return;
    }

    state = FocusSession(
      taskId: state.taskId,
      elapsedSeconds: state.elapsedSeconds,
      segmentStartedAt: DateTime.now(),
    );
    _startTicker();
  }

  void reset() {
    if (!state.isActive) {
      return;
    }

    _flushToDaily();
    _stopTicker();
    _dailyFlushedSeconds = 0;
    state = FocusSession(taskId: state.taskId);
  }

  void clear() {
    _flushToDaily();
    _stopTicker();
    _dailyFlushedSeconds = 0;
    state = const FocusSession();
  }
}

final focusSessionProvider =
    NotifierProvider<FocusSessionNotifier, FocusSession>(
  FocusSessionNotifier.new,
);
