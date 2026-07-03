import 'package:drift/drift.dart';

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get content => text().withDefault(const Constant(''))();

  TextColumn get domain => text()();

  IntColumn get wordCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get notionPageId => text().nullable()();

  TextColumn get notionUrl => text().nullable()();

  DateTimeColumn get notionLastEdited => dateTime().nullable()();

  BoolColumn get isNotionSynced =>
      boolean().withDefault(const Constant(false))();
}
