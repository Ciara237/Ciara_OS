import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/services/pdf/pdf_tokens.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Task backlog PDF export — palette follows app/system brightness.
class TaskExportPdfTemplate {
  TaskExportPdfTemplate(Brightness brightness)
      : _palette = PdfThemePalette.fromBrightness(brightness);

  final PdfThemePalette _palette;

  List<pw.Widget> buildContent({
    required List<Task> tasks,
    required String periodLabel,
  }) {
    final widgets = <pw.Widget>[
      _header(periodLabel),
      pw.SizedBox(height: 24),
    ];

    if (tasks.isEmpty) {
      widgets.add(_bodyText('No tasks to export.'));
      widgets.add(pw.SizedBox(height: 24));
      widgets.add(_footer());
      return widgets;
    }

    final completed =
        tasks.where((task) => task.status == TaskStatus.done).length;
    final inProgress =
        tasks.where((task) => task.status == TaskStatus.inProgress).length;
    final stuck =
        tasks.where((task) => task.status == TaskStatus.stuck).length;

    widgets.add(
      pw.Row(
        children: [
          pw.Expanded(child: _summaryBox('${tasks.length}', 'TOTAL')),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _summaryBox('$completed', 'COMPLETED')),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _summaryBox('$inProgress', 'IN PROGRESS')),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _summaryBox('$stuck', 'STUCK')),
        ],
      ),
    );
    widgets.add(pw.SizedBox(height: 28));

    final grouped = <Domain, List<Task>>{};
    for (final task in tasks) {
      grouped.putIfAbsent(task.domain, () => []).add(task);
    }

    for (final domain in Domain.values.where(grouped.containsKey)) {
      final domainTasks = grouped[domain]!;
      final accent = PdfTokens.domainColor(domain);
      widgets.addAll(_domainSection(domain, domainTasks, accent));
    }

    widgets.add(pw.SizedBox(height: 20));
    widgets.add(_footer());
    return widgets;
  }

  List<pw.Widget> _domainSection(
    Domain domain,
    List<Task> tasks,
    PdfColor accent,
  ) {
    final completed =
        tasks.where((task) => task.status == TaskStatus.done).length;
    final inProgress =
        tasks.where((task) => task.status == TaskStatus.inProgress).length;
    final stuck =
        tasks.where((task) => task.status == TaskStatus.stuck).length;

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
                        fontSize: 10,
                        color: accent,
                      ),
                    ),
                    pw.Text(
                      '${tasks.length} TASKS',
                      style: pw.TextStyle(
                        font: PdfTokens.bodyFont,
                        fontSize: 9,
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
            ),
          ),
      pw.SizedBox(height: 4),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        color: _palette.summaryBg,
        child: pw.Text(
          '$completed completed | $inProgress in progress | $stuck stuck',
          style: pw.TextStyle(
            font: PdfTokens.monoFont,
            fontSize: 8,
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
          pw.Expanded(
            flex: 28,
            child: _headerCell('TASK'),
          ),
          pw.Expanded(flex: 11, child: _headerCell('PRIORITY')),
          pw.Expanded(flex: 11, child: _headerCell('STATUS')),
          pw.Expanded(flex: 10, child: _headerCell('DEADLINE')),
        ],
      ),
    );
  }

  pw.Widget _taskRow({
    required Task task,
    required bool shaded,
  }) {
    final dateFormat = DateFormat('MMM dd').format;
    final deadline = task.deadline == null
        ? '-'
        : dateFormat(task.deadline!).toUpperCase();
    final isOverdue = task.deadline != null &&
        task.deadline!.isBefore(DateTime.now()) &&
        task.status != TaskStatus.done;
    final bg = shaded ? _palette.rowAlt : _palette.bg;

    return pw.Container(
      color: bg,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 28,
            child: _dataCell(
              task.title,
              _palette.onSurface,
              bold: true,
            ),
          ),
          pw.Expanded(
            flex: 11,
            child: _dataCell(
              PdfTokens.priorityLabel(task.priority),
              PdfTokens.priorityColor(task.priority),
            ),
          ),
          pw.Expanded(
            flex: 11,
            child: _dataCell(
              PdfTokens.statusLabel(task.status),
              PdfTokens.statusColor(
                task.status,
                neutral: _palette.onSurfaceMuted,
              ),
              bold: task.status == TaskStatus.stuck,
            ),
          ),
          pw.Expanded(
            flex: 10,
            child: _dataCell(
              isOverdue ? 'OVERDUE' : deadline,
              isOverdue ? PdfTokens.red : _palette.onSurfaceMuted,
              bold: isOverdue,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _header(String periodLabel) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              '> CIARA OS',
              style: pw.TextStyle(
                font: PdfTokens.monoBold,
                fontSize: 14,
                color: _palette.onSurface,
              ),
            ),
            pw.Text(
              'Task Export',
              style: pw.TextStyle(
                font: PdfTokens.bodyFont,
                fontSize: 11,
                color: _palette.onSurfaceMuted,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(height: 1, color: _palette.divider),
        pw.SizedBox(height: 8),
        pw.Text(
          PdfTokens.sanitize(periodLabel),
          style: pw.TextStyle(
            font: PdfTokens.monoFont,
            fontSize: 9,
            color: _palette.onSurfaceMuted,
          ),
        ),
      ],
    );
  }

  pw.Widget _summaryBox(String value, String label) {
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
              fontSize: 20,
              color: _palette.onSurface,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            PdfTokens.sanitize(label),
            style: pw.TextStyle(
              font: PdfTokens.monoFont,
              fontSize: 8,
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
        fontSize: 8,
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
        fontSize: 9,
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
          'Ciara OS v1.0.0 | Generated $generated | Private & confidential',
          style: pw.TextStyle(
            font: PdfTokens.monoFont,
            fontSize: 8,
            color: _palette.footer,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}
