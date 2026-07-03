import 'package:ciaraos/database/app_database.dart' hide Note;
import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/note.dart';
import 'package:drift/drift.dart';

class NoteRepository {
  NoteRepository(this._db);

  final AppDatabase _db;

  Stream<List<Note>> watchAll() {
    final query = _db.select(_db.notes)
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map(
          (rows) => rows.map(Note.fromRow).toList(),
        );
  }

  Stream<List<Note>> watchByDomain(Domain domain) {
    final query = _db.select(_db.notes)
      ..where((row) => row.domain.equals(domain.name))
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map(
          (rows) => rows.map(Note.fromRow).toList(),
        );
  }

  Future<List<Note>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      final rows = await (_db.select(_db.notes)
            ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
          .get();
      return rows.map(Note.fromRow).toList();
    }

    final pattern = '%$trimmed%';
    final rows = await (_db.select(_db.notes)
          ..where(
            (row) => row.title.like(pattern) | row.content.like(pattern),
          )
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .get();
    return rows.map(Note.fromRow).toList();
  }

  Future<Note?> getById(int id) async {
    final query = _db.select(_db.notes)..where((row) => row.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : Note.fromRow(row);
  }

  Future<Note?> getByNotionPageId(String notionPageId) async {
    final query = _db.select(_db.notes)
      ..where((row) => row.notionPageId.equals(notionPageId));
    final row = await query.getSingleOrNull();
    return row == null ? null : Note.fromRow(row);
  }

  Future<int> insert(NotesCompanion companion) {
    return _db.into(_db.notes).insert(companion);
  }

  Future<bool> update(NotesCompanion companion) {
    return _db.update(_db.notes).replace(companion);
  }

  Future<int> delete(int id) {
    return (_db.delete(_db.notes)..where((row) => row.id.equals(id))).go();
  }
}
