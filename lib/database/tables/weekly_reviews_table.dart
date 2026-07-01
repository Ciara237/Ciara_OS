import 'package:drift/drift.dart';

class WeeklyReviews extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get weekOf => dateTime()();

  TextColumn get whatWorked => text().nullable()();

  TextColumn get whatFailed => text().nullable()();

  TextColumn get whatToAutomate => text().nullable()();

  TextColumn get whatToCut => text().nullable()();

  TextColumn get improvementForNextWeek => text().nullable()();

  TextColumn get nextActions => text().nullable()();

  RealColumn get startedRate => real().nullable()();

  IntColumn get totalTasks =>
      integer().withDefault(const Constant(0))();

  IntColumn get startedTasks =>
      integer().withDefault(const Constant(0))();

  RealColumn get focusScore => real().nullable()();

  RealColumn get executionScore => real().nullable()();

  TextColumn get weeklyNarrative => text().nullable()();

  TextColumn get insightsJson => text().nullable()();

  BoolColumn get locked => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
