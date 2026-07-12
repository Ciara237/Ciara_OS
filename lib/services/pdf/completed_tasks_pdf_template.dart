import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/services/pdf/pdf_tokens.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Execution Archive PDF export — achievement-focused template.
class CompletedTasksPdfTemplate {
  CompletedTasksPdfTemplate(Brightness brightness)
      : _palette = PdfThemePalette.fromBrightness(brightness);

  final PdfThemePalette _palette;

  List<pw.Widget> buildContent({
    required List<Task> tasks,
    required String periodLabel,
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    final widgets = <pw.Widget>[
      _header(periodLabel, startDate, endDate),
      pw.SizedBox(height: 24),
    ];

    if (tasks.isEmpty) {
      widgets.add(_bodyText('No completed tasks in this period.'));
      widgets.add(pw.SizedBox(height: 24));
      widgets.add(_footer());
      return widgets;
    }

    // Achievement strip - 4 stat boxes
    final totalFocusHours = tasks.fold<int>(0, (sum, t) => sum + t.totalFocusedSeconds);
    final avgAccuracy = _calculateAvgAccuracy(tasks);
    final distinctDomains = tasks.map((t) => t.domain).toSet().length;

    widgets.add(
      pw.Row(
        children: [
          pw.Expanded(child: _statBox('${tasks.length}', 'COMPLETED')),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _statBox('${(totalFocusHours / 3600).toStringAsFixed(1)}h', 'FOCUS HOURS')),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _statBox(avgAccuracy, 'AVG ACCURACY')),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _statBox('$distinctDomains', 'DOMAINS')),
        ],
      ),
    );
    widgets.add(pw.SizedBox(height: 28));

    // Group by domain in specific order
    final domainOrder = [
      Domain.engineering,
      Domain.security,
      Domain.opportunities,
      Domain.builder,
      Domain.other,
    ];

    final grouped = <Domain, List<Task>>{};
    for (final task in tasks) {
      grouped.putIfAbsent(task.domain, () => []).add(task);
    }

    for (final domain in domainOrder.where(grouped.containsKey)) {
      final domainTasks = grouped[domain]!;
      final accent = PdfTokens.domainColor(domain);
      widgets.addAll(_domainSection(domain, domainTasks, accent));
    }

    widgets.add(pw.SizedBox(height: 20));
    widgets.add(_footer());
    return widgets;
  }

  String _calculateAvgAccuracy(List<Task> tasks) {
    final accuracies = tasks
        .where((t) => t.planningAccuracy != null)
        .map((t) => t.planningAccuracy!)
        .toList();
    if (accuracies.isEmpty) return '—';
    final avg = accuracies.reduce((a, b) => a + b) / accuracies.length;
    return '${(avg * 100).round()}%';
  }

  List<pw.Widget> _domainSection(
    Domain domain,
    List<Task> tasks,
    PdfColor accent,
  ) {
    final totalHours = tasks.fold<int>(0, (sum, t) => sum + t.totalFocusedSeconds);
    final hours = (totalHours / 3600).toStringAsFixed(1);
    final accuracies = tasks
        .where((t) => t.planningAccuracy != null)
        .map((t) => t.planningAccuracy!)
        .toList();
    final accuracy = accuracies.isEmpty
        ? '—'
        : '${(accuracies.reduce((a, b) => a + b) / accuracies.length * 100).round()}%';

    return [
      pw.Container(
        decoration: pw.BoxDecoration(
          color: _palette.domainHeaderBg,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(width: 4, color: accent),
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      PdfTokens.sanitize(domainLabel(domain)),
                      style: pw.TextStyle(
                        font: PdfTokens.monoBold,
                        fontSize: 9,
                        color: accent,
                      ),
                    ),
                    pw.Text(
                      '${tasks.length} TASKS',
                      style: pw.TextStyle(
                        font: PdfTokens.bodyFont,
                        fontSize: 8,
                        color: _palette.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 6),
      _taskTableHeader(),
      ...tasks.asMap().entries.map(
            (entry) => _taskRow(
              task: entry.value,
              shaded: entry.key.isOdd,
              accent: accent,
            ),
          ),
      pw.SizedBox(height: 4),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        color: _palette.summaryBg,
        child: pw.Text(
          '${tasks.length} tasks · $hours h focused · $accuracy avg accuracy',
          style: pw.TextStyle(
            font: PdfTokens.monoFont,
            fontSize: 7,
            color: _palette.onSurfaceMuted,
          ),
          textAlign: pw.TextAlign.right,
        ),
      ),
      pw.SizedBox(height: 20),
    ];
  }

  pw.Widget _taskTableHeader() {
    return pw.Container(
      color: _palette.summaryBg,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 180, child: _headerCell('TASK')),
          pw.SizedBox(width: 50, child: _headerCell('PRIORITY')),
          pw.SizedBox(width: 65, child: _headerCell('COMPLETED')),
          pw.SizedBox(width: 50, child: _headerCell('ESTIMATED')),
          pw.SizedBox(width: 50, child: _headerCell('ACTUAL')),
          pw.SizedBox(width: 45, child: _headerCell('ACCURACY')),
        ],
      ),
    );
  }

  pw.Widget _taskRow({
    required Task task,
    required bool shaded,
    required PdfColor accent,
  }) {
    final dateFormat = DateFormat('MMM dd').format;
    final completedDate = task.completedAt ?? task.updatedAt;
    final completed = dateFormat(completedDate);
    final estimated = task.estimatedDurationMinutes != null
        ? '${task.estimatedDurationMinutes}m'
        : '—';
    final actual = task.totalFocusedSeconds > 0
        ? '${(task.totalFocusedSeconds / 60).round()}m'
        : '—';
    final accuracyText = task.planningAccuracy == null
        ? '—'
        : '${(task.planningAccuracy! * 100).round()}%';
    final accuracyColor = task.planningAccuracy == null
        ? _palette.onSurfaceMuted
        : task.planningAccuracy! >= 0.8
            ? PdfTokens.green
            : task.planningAccuracy! >= 0.5
                ? PdfTokens.amber
                : PdfTokens.red;

    final bg = shaded ? _palette.rowAlt : _palette.bg;

    return pw.Container(
      color: bg,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 180,
            child: _dataCell(task.title, _palette.onSurface, bold: true),
          ),
          pw.SizedBox(
            width: 50,
            child: _dataCell(
              PdfTokens.priorityLabel(task.priority),
              PdfTokens.priorityColor(task.priority),
            ),
          ),
          pw.SizedBox(
            width: 65,
            child: _dataCell(completed, _palette.onSurfaceMuted),
          ),
          pw.SizedBox(
            width: 50,
            child: _dataCell(estimated, _palette.onSurfaceMuted),
          ),
          pw.SizedBox(
            width: 50,
            child: _dataCell(actual, _palette.onSurface),
          ),
          pw.SizedBox(
            width: 45,
            child: _dataCell(accuracyText, accuracyColor),
          ),
        ],
      ),
    );
  }

  pw.Widget _header(String periodLabel, DateTime? startDate, DateTime? endDate) {
    final dateRange = _formatDateRange(startDate, endDate);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              PdfTokens.sanitize('▸ CIARA OS'),
              style: pw.TextStyle(
                font: PdfTokens.monoBold,
                fontSize: 12,
                color: _palette.onSurface,
              ),
            ),
            pw.Text(
              'Execution Archive',
              style: pw.TextStyle(
                font: PdfTokens.bodyFont,
                fontSize: 10,
                color: _palette.onSurfaceMuted,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(height: 1, color: _palette.divider),
        pw.SizedBox(height: 8),
        pw.Text(
          dateRange,
          style: pw.TextStyle(
            font: PdfTokens.monoFont,
            fontSize: 9,
            color: _palette.onSurfaceMuted,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Completed tasks · archived record',
          style: pw.TextStyle(
            font: PdfTokens.monoFont,
            fontSize: 8,
            color: _palette.onSurfaceMuted,
          ),
        ),
      ],
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      return 'All time';
    }
    if (start == null) {
      return 'Until ${DateFormat("MMMM d, yyyy").format(end!)}';
    }
    if (end == null) {
      return 'From ${DateFormat("MMMM d, yyyy").format(start)}';
    }
    return '${DateFormat("MMMM d").format(start)} – ${DateFormat("MMMM d, yyyy").format(end)}';
  }

  pw.Widget _statBox(String value, String label) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: pw.BoxDecoration(
        color: _palette.summaryBg,
        border: pw.Border.all(color: _palette.summaryBorder),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            PdfTokens.sanitize(value),
            style: pw.TextStyle(
              font: PdfTokens.bodyBold,
              fontSize: 18,
              color: _palette.onSurface,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            PdfTokens.sanitize(label),
            style: pw.TextStyle(
              font: PdfTokens.monoFont,
              fontSize: 7,
              color: _palette.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _headerCell(String text) {
    return pw.Text(
      PdfTokens.sanitize(text),
      style: pw.TextStyle(
        font: PdfTokens.monoBold,
        fontSize: 7,
        color: _palette.onSurfaceMuted,
      ),
    );
  }

  pw.Widget _dataCell(
    String text,
    PdfColor color, {
    bool bold = false,
  }) {
    return pw.Text(
      PdfTokens.sanitize(text),
      style: pw.TextStyle(
        font: bold ? PdfTokens.bodyBold : PdfTokens.bodyFont,
        fontSize: 8,
        color: color,
      ),
    );
  }

  pw.Widget _bodyText(String text) {
    return pw.Text(
      PdfTokens.sanitize(text),
      style: pw.TextStyle(
        font: PdfTokens.bodyFont,
        fontSize: 11,
        color: _palette.onSurface,
      ),
    );
  }

  pw.Widget _footer() {
    final generated = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return pw.Column(
      children: [
        pw.Container(height: 1, color: _palette.divider),
        pw.SizedBox(height: 10),
        pw.Text(
          'Ciara OS v1.0.0  ·  Generated $generated  ·  Private & confidential',
          style: pw.TextStyle(
            font: PdfTokens.monoFont,
            fontSize: 7,
            color: _palette.footer,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}
