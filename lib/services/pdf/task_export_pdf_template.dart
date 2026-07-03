import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/services/pdf/pdf_tokens.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Stitch `task_export_template_light_professional` — light PDF layout.
class TaskExportPdfTemplate {
  List<pw.Widget> buildContent({
    required List<Task> tasks,
    required String periodLabel,
  }) {
    final widgets = <pw.Widget>[
      _lightHeader(periodLabel),
      pw.SizedBox(height: 24),
    ];

    if (tasks.isEmpty) {
      widgets.add(_bodyText('No tasks to export.'));
      widgets.add(pw.SizedBox(height: 24));
      widgets.add(_lightFooter());
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
    widgets.add(_lightFooter());
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
    final dateFormat = DateFormat('MMM dd').format;

    return [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: pw.BoxDecoration(
          color: PdfTokens.lightDomainHeaderBg,
          border: pw.Border(left: pw.BorderSide(color: accent, width: 4)),
          borderRadius: pw.BorderRadius.circular(4),
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
                color: PdfTokens.lightMuted,
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 6),
      pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(2.8),
          1: const pw.FlexColumnWidth(1.1),
          2: const pw.FlexColumnWidth(1.1),
          3: const pw.FlexColumnWidth(1),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfTokens.lightSummaryBg),
            children: [
              _headerCell('TASK'),
              _headerCell('PRIORITY'),
              _headerCell('STATUS'),
              _headerCell('DEADLINE'),
            ],
          ),
          ...tasks.asMap().entries.map((entry) {
            final task = entry.value;
            final bg =
                entry.key.isOdd ? PdfTokens.lightRowAlt : PdfTokens.lightBg;
            final deadline = task.deadline == null
                ? '-'
                : dateFormat(task.deadline!).toUpperCase();
            final isOverdue = task.deadline != null &&
                task.deadline!.isBefore(DateTime.now()) &&
                task.status != TaskStatus.done;

            return pw.TableRow(
              decoration: pw.BoxDecoration(
                color: bg,
                border: pw.Border(left: pw.BorderSide(color: accent, width: 2)),
              ),
              children: [
                _dataCell(
                  task.title,
                  PdfTokens.lightOnSurface,
                  bold: true,
                ),
                _dataCell(
                  PdfTokens.priorityLabel(task.priority),
                  PdfTokens.priorityColor(task.priority),
                ),
                _dataCell(
                  PdfTokens.statusLabel(task.status),
                  PdfTokens.statusColor(task.status),
                  bold: task.status == TaskStatus.stuck,
                ),
                _dataCell(
                  isOverdue ? 'OVERDUE' : deadline,
                  isOverdue ? PdfTokens.red : PdfTokens.lightMuted,
                  bold: isOverdue,
                ),
              ],
            );
          }),
        ],
      ),
      pw.SizedBox(height: 4),
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        color: PdfTokens.lightSummaryBg,
        child: pw.Text(
          '$completed completed | $inProgress in progress | $stuck stuck',
          style: pw.TextStyle(
            font: PdfTokens.monoFont,
            fontSize: 8,
            color: PdfTokens.lightMuted,
          ),
          textAlign: pw.TextAlign.right,
        ),
      ),
      pw.SizedBox(height: 20),
    ];
  }

  pw.Widget _lightHeader(String periodLabel) {
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
                color: PdfTokens.lightOnSurface,
              ),
            ),
            pw.Text(
              'Task Export',
              style: pw.TextStyle(
                font: PdfTokens.bodyFont,
                fontSize: 11,
                color: PdfTokens.lightMuted,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(height: 1, color: PdfTokens.lightDivider),
        pw.SizedBox(height: 8),
        pw.Text(
          PdfTokens.sanitize(periodLabel),
          style: pw.TextStyle(
            font: PdfTokens.monoFont,
            fontSize: 9,
            color: PdfTokens.lightMuted,
          ),
        ),
      ],
    );
  }

  pw.Widget _summaryBox(String value, String label) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: pw.BoxDecoration(
        color: PdfTokens.lightSummaryBg,
        border: pw.Border.all(color: PdfTokens.lightSummaryBorder),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            PdfTokens.sanitize(value),
            style: pw.TextStyle(
              font: PdfTokens.bodyBold,
              fontSize: 20,
              color: PdfTokens.lightOnSurface,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            PdfTokens.sanitize(label),
            style: pw.TextStyle(
              font: PdfTokens.monoFont,
              fontSize: 8,
              color: PdfTokens.lightMuted,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        PdfTokens.sanitize(text),
        style: pw.TextStyle(
          font: PdfTokens.monoBold,
          fontSize: 8,
          color: PdfTokens.lightMuted,
        ),
      ),
    );
  }

  pw.Widget _dataCell(
    String text,
    PdfColor color, {
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        PdfTokens.sanitize(text),
        style: pw.TextStyle(
          font: bold ? PdfTokens.bodyBold : PdfTokens.bodyFont,
          fontSize: 9,
          color: color,
        ),
      ),
    );
  }

  pw.Widget _bodyText(String text) {
    return pw.Text(
      PdfTokens.sanitize(text),
      style: pw.TextStyle(
        font: PdfTokens.bodyFont,
        fontSize: 11,
        color: PdfTokens.lightOnSurface,
      ),
    );
  }

  pw.Widget _lightFooter() {
    final generated = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return pw.Column(
      children: [
        pw.Container(height: 1, color: PdfTokens.lightDivider),
        pw.SizedBox(height: 10),
        pw.Text(
          'Ciara OS v1.0.0 | Generated $generated | Private & confidential',
          style: pw.TextStyle(
            font: PdfTokens.monoFont,
            fontSize: 8,
            color: PdfTokens.lightMuted,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}
