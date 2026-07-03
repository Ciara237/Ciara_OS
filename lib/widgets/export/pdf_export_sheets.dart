import 'package:ciaraos/widgets/export/export_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// Review screen export — Stitch PDF + CSV options.
Future<void> showReviewExportSheet({
  required BuildContext context,
  required Future<void> Function() onExportPdf,
  required Future<void> Function() onExportCsv,
}) {
  return showCiaraExportSheet(
    context: context,
    options: [
      ExportOption(
        title: 'Export as PDF',
        subtitle: 'Dark premium format · Best for digital viewing',
        icon: Icons.description_outlined,
        onExport: onExportPdf,
      ),
      ExportOption(
        title: 'Export as CSV',
        subtitle: 'Spreadsheet format · Opens in Excel or Sheets',
        icon: Icons.grid_on_outlined,
        onExport: onExportCsv,
      ),
    ],
  );
}

/// Tasks backlog export — Stitch PDF + CSV options.
Future<void> showTasksExportSheet({
  required BuildContext context,
  required Future<void> Function() onExportPdf,
  required Future<void> Function() onExportCsv,
}) {
  return showCiaraExportSheet(
    context: context,
    overline: 'EXPORT TASKS',
    options: [
      ExportOption(
        title: 'Export as PDF',
        subtitle: 'Light professional format · Best for printing',
        icon: Icons.description_outlined,
        onExport: onExportPdf,
      ),
      ExportOption(
        title: 'Export as CSV',
        subtitle: 'Spreadsheet format · Opens in Excel or Sheets',
        icon: Icons.grid_on_outlined,
        onExport: onExportCsv,
      ),
    ],
  );
}
