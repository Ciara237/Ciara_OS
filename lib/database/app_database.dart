import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

import 'tables/focus_sessions_table.dart';
import 'tables/opportunities_table.dart';
import 'tables/projects_table.dart';
import 'tables/tasks_table.dart';
import 'tables/weekly_reviews_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Tasks,
    Projects,
    Opportunities,
    WeeklyReviews,
    FocusSessions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'ciara_os'));

  static AppDatabase? _instance;

  /// Singleton accessor referenced by [database_provider].
  static AppDatabase get instance => _instance ??= AppDatabase();

  @visibleForTesting
  static AppDatabase forTesting(QueryExecutor executor) {
    return AppDatabase(executor);
  }

  static Future<void> closeInstance() async {
    await _instance?.close();
    _instance = null;
  }

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(
              opportunities,
              opportunities.leadQuality,
            );
          }
          if (from < 3) {
            await migrator.addColumn(
              opportunities,
              opportunities.location,
            );
          }
          if (from < 4) {
            await migrator.addColumn(
              projects,
              projects.timeAllocationDays,
            );
          }
          if (from < 5) {
            await migrator.createTable(focusSessions);
            await migrator.addColumn(
              tasks,
              tasks.estimatedDurationMinutes,
            );
            await migrator.addColumn(
              tasks,
              tasks.totalFocusedSeconds,
            );
            await migrator.addColumn(
              tasks,
              tasks.focusSessionCount,
            );
            await migrator.addColumn(
              tasks,
              tasks.planningAccuracy,
            );
            await migrator.addColumn(
              tasks,
              tasks.lastFocusSessionAt,
            );
          }
          if (from < 6) {
            await migrator.addColumn(
              weeklyReviews,
              weeklyReviews.improvementForNextWeek,
            );
            await migrator.addColumn(
              weeklyReviews,
              weeklyReviews.executionScore,
            );
            await migrator.addColumn(
              weeklyReviews,
              weeklyReviews.weeklyNarrative,
            );
            await migrator.addColumn(
              weeklyReviews,
              weeklyReviews.insightsJson,
            );
          }
        },
      );
}
