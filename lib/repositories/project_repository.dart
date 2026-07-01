import 'package:ciaraos/database/app_database.dart' hide Project;
import 'package:ciaraos/models/project.dart';
import 'package:drift/drift.dart';

class ProjectRepository {
  ProjectRepository(this._db);

  final AppDatabase _db;

  Stream<List<Project>> watchAll() {
    final query = _db.select(_db.projects)
      ..orderBy([(project) => OrderingTerm.desc(project.updatedAt)]);

    return query.watch().map(
          (rows) => rows.map(Project.fromRow).toList(),
        );
  }

  Future<Project?> getById(int id) async {
    final query = _db.select(_db.projects)
      ..where((project) => project.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : Project.fromRow(row);
  }

  Future<int> insert(ProjectsCompanion companion) {
    return _db.into(_db.projects).insert(companion);
  }

  Future<bool> update(ProjectsCompanion companion) {
    return _db.update(_db.projects).replace(companion);
  }

  Future<int> delete(int id) {
    return (_db.delete(_db.projects)..where((project) => project.id.equals(id)))
        .go();
  }

  Future<void> deleteAll() {
    return _db.delete(_db.projects).go();
  }
}
