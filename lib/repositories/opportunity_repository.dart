import 'package:ciaraos/database/app_database.dart' hide Opportunity;
import 'package:ciaraos/models/enums/opportunity_status.dart';
import 'package:ciaraos/models/opportunity.dart';
import 'package:drift/drift.dart';

class OpportunityRepository {
  OpportunityRepository(this._db);

  final AppDatabase _db;

  Stream<List<Opportunity>> watchAll() {
    final query = _db.select(_db.opportunities)
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map(
          (rows) => rows.map(Opportunity.fromRow).toList(),
        );
  }

  Stream<List<Opportunity>> watchByStatus(OpportunityStatus status) {
    final query = _db.select(_db.opportunities)
      ..where((row) => row.status.equals(status.name))
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map(
          (rows) => rows.map(Opportunity.fromRow).toList(),
        );
  }

  Future<Opportunity?> getById(int id) async {
    final query = _db.select(_db.opportunities)
      ..where((row) => row.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : Opportunity.fromRow(row);
  }

  Future<int> insert(OpportunitiesCompanion companion) {
    return _db.into(_db.opportunities).insert(companion);
  }

  Future<bool> update(OpportunitiesCompanion companion) {
    return _db.update(_db.opportunities).replace(companion);
  }

  Future<int> delete(int id) {
    return (_db.delete(_db.opportunities)..where((row) => row.id.equals(id)))
        .go();
  }

  Future<void> deleteAll() {
    return _db.delete(_db.opportunities).go();
  }
}
