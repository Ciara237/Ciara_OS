import 'package:drift/drift.dart';

class Opportunities extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get organization => text()();

  TextColumn get location => text().withDefault(const Constant(''))();

  TextColumn get type => text()();

  TextColumn get status =>
      text().withDefault(const Constant('researching'))();

  DateTimeColumn get deadline => dateTime().nullable()();

  TextColumn get fitNotes => text().nullable()();

  TextColumn get documents => text().nullable()();

  IntColumn get documentsTotal =>
      integer().withDefault(const Constant(0))();

  IntColumn get documentsReady =>
      integer().withDefault(const Constant(0))();

  TextColumn get link => text().nullable()();

  /// 1–3 rating; null = unrated.
  IntColumn get leadQuality => integer().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
