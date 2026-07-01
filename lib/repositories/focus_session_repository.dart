import 'package:ciaraos/database/app_database.dart';
import 'package:ciaraos/models/enums/focus_quality.dart';
import 'package:ciaraos/models/focus_session_record.dart';
import 'package:ciaraos/repositories/task_repository.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:drift/drift.dart';

class FocusSessionRepository {
  FocusSessionRepository(this._db);

  final AppDatabase _db;

  Future<FocusSessionRecord?> getActiveSession() async {
    final row = await (_db.select(_db.focusSessions)
          ..where((s) => s.endedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : FocusSessionRecord.fromRow(row);
  }

  Stream<FocusSessionRecord?> watchActiveSession() {
    final query = _db.select(_db.focusSessions)
      ..where((s) => s.endedAt.isNull())
      ..limit(1);

    return query.watchSingleOrNull().map(
          (row) => row == null ? null : FocusSessionRecord.fromRow(row),
        );
  }

  Future<List<FocusSessionRecord>> getSessionsForTask(int taskId) async {
    final rows = await (_db.select(_db.focusSessions)
          ..where((s) => s.taskId.equals(taskId))
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
        .get();
    return rows.map(FocusSessionRecord.fromRow).toList();
  }

  Future<List<FocusSessionRecord>> getCompletedSessionsForDay(
    DateTime day,
  ) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final rows = await (_db.select(_db.focusSessions)
          ..where(
            (s) =>
                s.endedAt.isNotNull() &
                s.endedAt.isBiggerOrEqualValue(start) &
                s.endedAt.isSmallerThanValue(end),
          ))
        .get();
    return rows.map(FocusSessionRecord.fromRow).toList();
  }

  Future<List<FocusSessionRecord>> getCompletedSessionsForWeek(
    DateTime weekMonday,
  ) async {
    final start = DateTime(
      weekMonday.year,
      weekMonday.month,
      weekMonday.day,
    );
    final end = start.add(const Duration(days: 7));
    final rows = await (_db.select(_db.focusSessions)
          ..where(
            (s) =>
                s.endedAt.isNotNull() &
                s.endedAt.isBiggerOrEqualValue(start) &
                s.endedAt.isSmallerThanValue(end),
          ))
        .get();
    return rows.map(FocusSessionRecord.fromRow).toList();
  }

  Future<int> insertSession(FocusSessionsCompanion companion) {
    return _db.into(_db.focusSessions).insert(companion);
  }

  Future<bool> updateSession(FocusSessionsCompanion companion) {
    return _db.update(_db.focusSessions).replace(companion);
  }

  Future<void> deleteSession(int id) async {
    await (_db.delete(_db.focusSessions)..where((s) => s.id.equals(id))).go();
  }

  Future<FocusSessionRecord> startSession(int taskId) async {
    final existing = await getActiveSession();
    if (existing != null) {
      if (existing.taskId == taskId) {
        if (!existing.isRunning) {
          return resumeSession(existing);
        }
        return existing;
      }
      throw StateError('Another task already has an active focus session.');
    }

    final now = DateTime.now();
    final id = await insertSession(
      FocusSessionsCompanion.insert(
        taskId: taskId,
        startedAt: now,
        segmentStartedAt: Value(now),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final created = await (_db.select(_db.focusSessions)
          ..where((s) => s.id.equals(id)))
        .getSingle();
    return FocusSessionRecord.fromRow(created);
  }

  Future<FocusSessionRecord> resumeSession(FocusSessionRecord session) async {
    final now = DateTime.now();
    final updated = session.copyWith(
      segmentStartedAt: now,
      updatedAt: now,
    );
    await updateSession(updated.toCompanion());
    return updated;
  }

  Future<FocusSessionRecord> pauseSession(FocusSessionRecord session) async {
    final elapsed = session.liveElapsedSeconds;
    final now = DateTime.now();
    final updated = session.copyWith(
      pausedElapsedSeconds: elapsed,
      clearSegmentStartedAt: true,
      updatedAt: now,
    );
    await updateSession(updated.toCompanion());
    return updated;
  }

  Future<FocusSessionRecord> completeSession({
    required FocusSessionRecord session,
    required FocusQuality quality,
    required TaskRepository taskRepo,
  }) async {
    final duration = session.liveElapsedSeconds;
    final now = DateTime.now();
    final goalReached = duration >= deepWorkGoalSeconds;

    final completed = session.copyWith(
      endedAt: now,
      durationSeconds: duration,
      focusQuality: quality,
      goalReached: goalReached,
      pausedElapsedSeconds: duration,
      clearSegmentStartedAt: true,
      updatedAt: now,
    );
    await updateSession(completed.toCompanion());

    final task = await taskRepo.getById(session.taskId);
    if (task != null) {
      await taskRepo.update(
        task
            .copyWith(
              totalFocusedSeconds: task.totalFocusedSeconds + duration,
              focusSessionCount: task.focusSessionCount + 1,
              lastFocusSessionAt: now,
              started: false,
              updatedAt: now,
            )
            .toCompanion(),
      );
    }

    return completed;
  }

  Future<FocusSessionRecord> persistProgress(FocusSessionRecord session) async {
    if (!session.isRunning) {
      return session;
    }
    final elapsed = session.liveElapsedSeconds;
    final now = DateTime.now();
    final updated = session.copyWith(
      pausedElapsedSeconds: elapsed,
      segmentStartedAt: now,
      updatedAt: now,
    );
    await updateSession(updated.toCompanion());
    return updated;
  }

  Future<void> discardSession(FocusSessionRecord session) async {
    await deleteSession(session.id);
  }
}
