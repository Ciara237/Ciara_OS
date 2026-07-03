import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class ReviewPdfExportSheet extends StatefulWidget {
  const ReviewPdfExportSheet({
    super.key,
    required this.onExportWeeklyReview,
    required this.onExportTaskBreakdown,
  });

  final Future<void> Function() onExportWeeklyReview;
  final Future<void> Function() onExportTaskBreakdown;

  @override
  State<ReviewPdfExportSheet> createState() => _ReviewPdfExportSheetState();
}

class _ReviewPdfExportSheetState extends State<ReviewPdfExportSheet> {
  bool _isExporting = false;

  Future<void> _runExport(Future<void> Function() action) async {
    if (_isExporting) {
      return;
    }

    setState(() => _isExporting = true);
    try {
      await action();
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Export Report',
              style: AppTypography.headingMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_isExporting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: colorScheme.primary),
                title: Text(
                  'Export Weekly Review PDF',
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Executive summary, task breakdown, and priorities',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () => _runExport(widget.onExportWeeklyReview),
              ),
              ListTile(
                leading: Icon(Icons.table_rows, color: colorScheme.primary),
                title: Text(
                  'Export Task Breakdown PDF',
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Tasks created this week in export table format',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () => _runExport(widget.onExportTaskBreakdown),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TasksPdfExportSheet extends StatefulWidget {
  const TasksPdfExportSheet({
    super.key,
    required this.onExport,
  });

  final Future<void> Function() onExport;

  @override
  State<TasksPdfExportSheet> createState() => _TasksPdfExportSheetState();
}

class _TasksPdfExportSheetState extends State<TasksPdfExportSheet> {
  bool _isExporting = false;

  Future<void> _runExport() async {
    if (_isExporting) {
      return;
    }

    setState(() => _isExporting = true);
    try {
      await widget.onExport();
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Export Tasks',
              style: AppTypography.headingMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_isExporting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: colorScheme.primary),
                title: Text(
                  'Export Current View as PDF',
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Exports the filtered backlog list',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: _runExport,
              ),
          ],
        ),
      ),
    );
  }
}
