import 'package:flutter/material.dart';

/// Deterministic insight surfaced during the Executive Debrief.
class ExecutionInsight {
  const ExecutionInsight({
    required this.title,
    required this.description,
    required this.recommendation,
    required this.icon,
    this.iconColorKind = InsightIconColorKind.primary,
  });

  final String title;
  final String description;
  final String recommendation;
  final IconData icon;
  final InsightIconColorKind iconColorKind;
}

enum InsightIconColorKind {
  primary,
  tertiary,
  secondary,
}
