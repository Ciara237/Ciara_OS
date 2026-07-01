import 'package:ciaraos/database/app_database.dart' hide WeeklyReview;
import 'package:ciaraos/models/weekly_review.dart';
import 'package:drift/drift.dart';

class WeeklyReviewRepository {
  WeeklyReviewRepository(this._db);

  final AppDatabase _db;

  Stream<List<WeeklyReview>> watchAll() {
    final query = _db.select(_db.weeklyReviews)
      ..orderBy([(row) => OrderingTerm.desc(row.weekOf)]);

    return query.watch().map(
          (rows) => rows.map(WeeklyReview.fromRow).toList(),
        );
  }

  Future<WeeklyReview?> getByWeek(DateTime weekOf) async {
    final query = _db.select(_db.weeklyReviews)
      ..where((row) => row.weekOf.equals(weekOf));
    final row = await query.getSingleOrNull();
    return row == null ? null : WeeklyReview.fromRow(row);
  }

  Future<int> insert(WeeklyReviewsCompanion companion) {
    return _db.into(_db.weeklyReviews).insert(companion);
  }

  Future<bool> update(WeeklyReviewsCompanion companion) {
    return _db.update(_db.weeklyReviews).replace(companion);
  }

  Future<void> lockReview(int id) async {
    await (_db.update(_db.weeklyReviews)..where((row) => row.id.equals(id)))
        .write(
      WeeklyReviewsCompanion(
        locked: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteAll() {
    return _db.delete(_db.weeklyReviews).go();
  }
}
