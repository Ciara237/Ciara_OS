import 'dart:convert';

import 'package:ciaraos/database/app_database.dart' as db;
import 'package:ciaraos/models/execution_insight.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart';

class WeeklyReview {
  const WeeklyReview({
    required this.id,
    required this.weekOf,
    this.whatWorked,
    this.whatSlowedDown,
    this.improvementForNextWeek,
    this.nextActions = const [],
    this.startedRate,
    required this.totalTasks,
    required this.startedTasks,
    this.focusScore,
    this.executionScore,
    this.weeklyNarrative,
    this.insights = const [],
    required this.locked,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final DateTime weekOf;
  final String? whatWorked;
  final String? whatSlowedDown;
  final String? improvementForNextWeek;
  final List<String> nextActions;
  final double? startedRate;
  final int totalTasks;
  final int startedTasks;
  final double? focusScore;
  final double? executionScore;
  final String? weeklyNarrative;
  final List<ExecutionInsight> insights;
  final bool locked;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory WeeklyReview.fromRow(db.WeeklyReview row) {
    return WeeklyReview(
      id: row.id,
      weekOf: row.weekOf,
      whatWorked: row.whatWorked,
      whatSlowedDown: row.whatFailed,
      improvementForNextWeek: row.improvementForNextWeek,
      nextActions: _nextActionsFromJson(row.nextActions),
      startedRate: row.startedRate,
      totalTasks: row.totalTasks,
      startedTasks: row.startedTasks,
      focusScore: row.focusScore,
      executionScore: row.executionScore,
      weeklyNarrative: row.weeklyNarrative,
      insights: _insightsFromJson(row.insightsJson),
      locked: row.locked,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static List<String> _nextActionsFromJson(String? json) {
    if (json == null || json.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded.map((action) => action as String).toList();
  }

  static String? _nextActionsToJson(List<String> actions) {
    if (actions.isEmpty) {
      return null;
    }

    return jsonEncode(actions);
  }

  static List<ExecutionInsight> _insightsFromJson(String? json) {
    if (json == null || json.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded.map((item) {
      final map = item as Map<String, dynamic>;
      return ExecutionInsight(
        title: map['title'] as String,
        description: map['description'] as String,
        recommendation: map['recommendation'] as String,
        icon: Icons.lightbulb_outline,
        iconColorKind: InsightIconColorKind.values.byName(
          map['iconColorKind'] as String? ?? 'primary',
        ),
      );
    }).toList();
  }

  static String? _insightsToJson(List<ExecutionInsight> insights) {
    if (insights.isEmpty) {
      return null;
    }

    return jsonEncode(
      insights
          .map(
            (insight) => {
              'title': insight.title,
              'description': insight.description,
              'recommendation': insight.recommendation,
              'iconColorKind': insight.iconColorKind.name,
            },
          )
          .toList(),
    );
  }

  db.WeeklyReviewsCompanion toCompanion({bool forInsert = false}) {
    return db.WeeklyReviewsCompanion(
      id: forInsert ? const Value.absent() : Value(id),
      weekOf: Value(weekOf),
      whatWorked: Value(whatWorked),
      whatFailed: Value(whatSlowedDown),
      whatToAutomate: const Value.absent(),
      whatToCut: const Value.absent(),
      improvementForNextWeek: Value(improvementForNextWeek),
      nextActions: Value(_nextActionsToJson(nextActions)),
      startedRate: Value(startedRate),
      totalTasks: Value(totalTasks),
      startedTasks: Value(startedTasks),
      focusScore: Value(focusScore),
      executionScore: Value(executionScore),
      weeklyNarrative: Value(weeklyNarrative),
      insightsJson: Value(_insightsToJson(insights)),
      locked: Value(locked),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
