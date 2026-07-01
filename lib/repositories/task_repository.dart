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
      ..where((task) => task.today.equals(true))
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
