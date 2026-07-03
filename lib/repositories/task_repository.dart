import 'package:ciaraos/database/app_database.dart' hide Task;
import 'package:ciaraos/models/task.dart';
import 'package:drift/drift.dart';

class TaskRepository {
  TaskRepository(this._db);

  final AppDatabase _db;

  Stream<List<Task>> watchAll() {
    final query = _db.select(_db.tasks)
      ..orderBy([(task) => OrderingTerm.desc(task.updatedAt)]);

    return query.watch().map(
          (rows) => rows.map(Task.fromRow).toList(),
        );
  }

  Stream<List<Task>> watchToday() {
    final query = _db.select(_db.tasks)
      ..where(
        (task) => task.today.equals(true) & task.status.isNotValue('done'),
      )
      ..orderBy([(task) => OrderingTerm.desc(task.updatedAt)]);

    return query.watch().map(
          (rows) => rows.map(Task.fromRow).toList(),
        );
  }

  Future<Task?> getById(int id) async {
    final query = _db.select(_db.tasks)..where((task) => task.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : Task.fromRow(row);
  }

  Future<int> insert(TasksCompanion companion) {
    return _db.into(_db.tasks).insert(companion);
  }

  Future<bool> update(TasksCompanion companion) {
    return _db.update(_db.tasks).replace(companion);
  }

  Future<int> delete(int id) {
    return (_db.delete(_db.tasks)..where((task) => task.id.equals(id))).go();
  }

  Future<void> deleteAll() {
    return _db.delete(_db.tasks).go();
  }

  Future<List<Task>> getTasksCompletedInWeek(DateTime weekStart) async {
    final normalizedStart = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final normalizedEnd = normalizedStart.add(const Duration(days: 7));
    final rows = await (_db.select(_db.tasks)..where(
          (task) =>
              task.status.equals('done') &
              task.updatedAt.isBiggerOrEqualValue(normalizedStart) &
              task.updatedAt.isSmallerThanValue(normalizedEnd),
        ))
        .get();
    return rows.map(Task.fromRow).toList();
  }

  Stream<List<Task>> watchCompleted() {
    final query = _db.select(_db.tasks)
      ..where((task) => task.status.equals('done'))
      ..orderBy([(task) => OrderingTerm.desc(task.updatedAt)]);

    return query.watch().map(
          (rows) => rows.map(Task.fromRow).toList(),
        );
  }

  Future<List<Task>> getCompletedBefore(
    DateTime before, {
    int limit = 20,
  }) async {
    final rows = await (_db.select(_db.tasks)
          ..where(
            (task) =>
                task.status.equals('done') &
                task.updatedAt.isSmallerThanValue(before),
          )
          ..orderBy([(task) => OrderingTerm.desc(task.updatedAt)])
          ..limit(limit))
        .get();
    return rows.map(Task.fromRow).toList();
  }

  Future<int> countCompleted() async {
    final countExp = _db.tasks.id.count();
    final query = _db.selectOnly(_db.tasks)
      ..addColumns([countExp])
      ..where(_db.tasks.status.equals('done'));
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<List<Task>> getIncompleteTasks() async {
    final rows = await (_db.select(_db.tasks)
          ..where((task) => task.status.isNotValue('done'))
          ..orderBy([
            (task) => OrderingTerm.desc(task.priority),
            (task) => OrderingTerm.desc(task.updatedAt),
          ]))
        .get();
    return rows.map(Task.fromRow).toList();
  }

  Future<List<Task>> getTasksForWeek(DateTime weekStart) async {
    final normalizedStart = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final normalizedEnd = normalizedStart.add(const Duration(days: 7));
    final rows = await (_db.select(_db.tasks)..where(
          (task) =>
              task.createdAt.isBiggerOrEqualValue(normalizedStart) &
              task.createdAt.isSmallerThanValue(normalizedEnd),
        ))
        .get();
    return rows.map(Task.fromRow).toList();
  }

  Future<void> incrementPostponeCount(int id) async {
    final task = await getById(id);
    if (task == null) {
      return;
    }

    await (_db.update(_db.tasks)..where((row) => row.id.equals(id))).write(
      TasksCompanion(
        postponeCount: Value(task.postponeCount + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
