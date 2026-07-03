import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/focus_session_record.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/models/weekly_review.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:ciaraos/services/pdf_export_delivery.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/utils/review_stats_utils.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// TODO: embed Inter + JetBrains Mono TTF files in Phase 2 for brand-accurate PDF typography
typedef FocusSession = FocusSessionRecord;

class PdfExportService {
  static final _bodyFont = pw.Font.helvetica();
  static final _monoFont = pw.Font.courier();
  static final _bodyBold = pw.Font.helveticaBold();
  static final _monoBold = pw.Font.courierBold();

  static const _bg = PdfColor.fromInt(0xFF081425);
  static const _onSurface = PdfColor.fromInt(0xFFD8E3FB);
  static const _onSurfaceVariant = PdfColor.fromInt(0xFFC5C6CD);
  static const _primary = PdfColor.fromInt(0xFFB9C7E0);
  static const _surfaceHigh = PdfColor.fromInt(0xFF1F2A3C);
  static const _surfaceLow = PdfColor.fromInt(0xFF111C2D);
  static const _outline = PdfColor.fromInt(0xFF44474C);

  /// Built-in PDF fonts (Helvetica/Courier) are Latin-1 only.
  static String _pdfText(String text) {
    return text
        .replaceAll('\u2014', '-')
        .replaceAll('\u2013', '-')
        .replaceAll('\u2022', '*')
        .replaceAll('\u00B7', ' | ')
        .replaceAll('\u25A1', '[]');
  }

  Future<void> exportWeeklyReview({
    required WeeklyReview review,
    required List<Task> tasksThisWeek,
    required List<FocusSession> sessionsThisWeek,
  }) async {
    final pdf = pw.Document(
      title: 'Ciara OS Weekly Review',
      creator: 'Ciara OS',
    );

    pdf.addPage(
      _reviewPage(
        weekOf: review.weekOf,
        child: _buildExecutiveSummary(
          review: review,
          sessions: sessionsThisWeek,
        ),
      ),
    );
    pdf.addPage(
      _reviewPage(
        weekOf: review.weekOf,
        child: _buildTaskBreakdown(tasksThisWeek),
      ),
    );
    pdf.addPage(
      _reviewPage(
        weekOf: review.weekOf,
        child: _buildNextWeekPriorities(review),
      ),
    );

    await deliverPdf(
      bytes: await pdf.save(),
      filename: 'ciara_os_review_${_weekLabel(review.weekOf)}.pdf',
    );
  }

  Future<void> exportTasksBacklog({
    required List<Task> tasks,
    required String periodLabel,
  }) async {
    final pdf = pw.Document(
      title: 'Ciara OS Task Export',
      creator: 'Ciara OS',
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        build: (context) => _buildTasksBacklogContent(
          tasks: tasks,
          periodLabel: periodLabel,
        ),
      ),
    );

    await deliverPdf(
      bytes: await pdf.save(),
      filename: 'ciara_os_tasks_${_sanitizeFilename(periodLabel)}.pdf',
    );
  }

  pw.Page _reviewPage({
    required DateTime weekOf,
    required pw.Widget child,
  }) {
    return pw.Page(
      pageTheme: _pageTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _reviewHeader(weekOf),
          pw.SizedBox(height: 20),
          pw.Expanded(child: child),
          pw.SizedBox(height: 16),
          _footer(),
        ],
      ),
    );
  }

  pw.PageTheme _pageTheme() {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      theme: pw.ThemeData.withFont(
        base: _bodyFont,
        bold: _bodyBold,
      ),
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Container(color: _bg),
      ),
    );
  }

  pw.Widget _reviewHeader(DateTime weekOf) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(
              '[]',
              style: pw.TextStyle(
                font: _monoFont,
                fontSize: 14,
                color: _primary,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              'CIARA OS',
              style: pw.TextStyle(
                font: _monoBold,
                fontSize: 12,
                color: _primary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Weekly Executive Debrief',
          style: pw.TextStyle(
            font: _bodyBold,
            fontSize: 18,
            color: _onSurface,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Week of ${_pdfText(reviewWeekRangeLabel(weekOf))}',
          style: pw.TextStyle(
            font: _bodyFont,
            fontSize: 11,
            color: _onSurfaceVariant,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Divider(color: _outline, thickness: 0.5),
      ],
    );
  }

  pw.Widget _tasksExportHeader(String periodLabel) {
    final dateLabel = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(
              '[]',
              style: pw.TextStyle(font: _monoFont, fontSize: 14, color: _primary),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              'CIARA OS',
              style: pw.TextStyle(
                font: _monoBold,
                fontSize: 12,
                color: _primary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Task Export - $dateLabel',
          style: pw.TextStyle(
            font: _bodyBold,
            fontSize: 16,
            color: _onSurface,
          ),
        ),
        if (periodLabel.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            periodLabel,
            style: pw.TextStyle(
              font: _monoFont,
              fontSize: 10,
              color: _onSurfaceVariant,
            ),
          ),
        ],
        pw.SizedBox(height: 12),
        pw.Divider(color: _outline, thickness: 0.5),
      ],
    );
  }

  pw.Widget _footer() {
    final generated = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return pw.Text(
      'Ciara OS v1.0.0 | Generated $generated | Private & confidential',
      style: pw.TextStyle(
        font: _monoFont,
        fontSize: 8,
        color: _onSurfaceVariant,
      ),
      textAlign: pw.TextAlign.center,
    );
  }

  pw.Widget _buildExecutiveSummary({
    required WeeklyReview review,
    required List<FocusSession> sessions,
  }) {
    final score = (review.executionScore ?? review.focusScore ?? 0).round();
    final startedPercent = review.startedRate == null
        ? '-'
        : '${(review.startedRate! * 100).round()}%';
    final tasksLabel = '${review.startedTasks}/${review.totalTasks}';
    final focusSeconds = sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationSeconds,
    );
    final focusLabel = formatFocusUptime(focusSeconds);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionLabel('EXECUTION SCORE'),
        pw.SizedBox(height: 8),
        pw.Text(
          '$score/100',
          style: pw.TextStyle(
            font: _bodyBold,
            fontSize: 32,
            color: _primary,
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: _surfaceHigh,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _metricCell('STARTED RATE', startedPercent),
              _metricCell('TASKS', tasksLabel),
              _metricCell('FOCUS', focusLabel),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        _sectionLabel('WEEKLY NARRATIVE'),
        pw.SizedBox(height: 8),
        _bodyText(review.weeklyNarrative ?? 'No narrative recorded.'),
        pw.SizedBox(height: 16),
        _sectionLabel('WHAT WORKED'),
        pw.SizedBox(height: 8),
        _bodyText(review.whatWorked ?? '-'),
        pw.SizedBox(height: 16),
        _sectionLabel('WHAT FAILED'),
        pw.SizedBox(height: 8),
        _bodyText(review.whatSlowedDown ?? '-'),
        pw.SizedBox(height: 16),
        _sectionLabel('IMPROVEMENT FOR NEXT WEEK'),
        pw.SizedBox(height: 8),
        _bodyText(review.improvementForNextWeek ?? '-'),
      ],
    );
  }

  pw.Widget _metricCell(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: _monoFont,
            fontSize: 8,
            color: _onSurfaceVariant,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          _pdfText(value),
          style: pw.TextStyle(
            font: _bodyBold,
            fontSize: 14,
            color: _onSurface,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTaskBreakdown(List<Task> tasks) {
    if (tasks.isEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionLabel('TASK BREAKDOWN'),
          pw.SizedBox(height: 12),
          _bodyText('No tasks recorded for this week.'),
        ],
      );
    }

    final headerStyle = pw.TextStyle(
      font: _monoBold,
      fontSize: 8,
      color: _onSurface,
    );
    final cellStyle = pw.TextStyle(
      font: _bodyFont,
      fontSize: 9,
      color: _onSurface,
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionLabel('TASK BREAKDOWN'),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: _outline, width: 0.3),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1.4),
            2: const pw.FlexColumnWidth(1.2),
            3: const pw.FlexColumnWidth(0.8),
            4: const pw.FlexColumnWidth(0.8),
            5: const pw.FlexColumnWidth(0.9),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _surfaceHigh),
              children: [
                _tableCell('Task', headerStyle),
                _tableCell('Domain', headerStyle),
                _tableCell('Status', headerStyle),
                _tableCell('Est', headerStyle),
                _tableCell('Actual', headerStyle),
                _tableCell('Accuracy', headerStyle),
              ],
            ),
            ...tasks.asMap().entries.map((entry) {
              final task = entry.value;
              final isOdd = entry.key.isOdd;
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: isOdd ? _surfaceLow : _bg,
                ),
                children: [
                  _tableCell(task.title, cellStyle),
                  _tableCell(domainLabel(task.domain), cellStyle),
                  _tableCell(_taskStatusLabel(task.status), cellStyle),
                  _tableCell(
                    formatEstimatedMinutes(task.estimatedDurationMinutes),
                    cellStyle,
                  ),
                  _tableCell(
                    formatDurationMinutes(task.totalFocusedSeconds),
                    cellStyle,
                  ),
                  _tableCell(
                    formatPlanningAccuracy(task.planningAccuracy),
                    cellStyle,
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildNextWeekPriorities(WeeklyReview review) {
    final actions = review.nextActions;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionLabel('NEXT WEEK PRIORITIES'),
        pw.SizedBox(height: 12),
        if (actions.isEmpty)
          _bodyText('No next actions recorded.')
        else
          ...actions.map(
            (action) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '*',
                    style: pw.TextStyle(
                      font: _bodyFont,
                      fontSize: 11,
                      color: _primary,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Text(
                      _pdfText(action),
                      style: pw.TextStyle(
                        font: _bodyFont,
                        fontSize: 11,
                        color: _onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<pw.Widget> _buildTasksBacklogContent({
    required List<Task> tasks,
    required String periodLabel,
  }) {
    final widgets = <pw.Widget>[
      _tasksExportHeader(periodLabel),
      pw.SizedBox(height: 16),
    ];

    if (tasks.isEmpty) {
      widgets.add(_bodyText('No tasks to export.'));
      widgets.add(pw.SizedBox(height: 24));
      widgets.add(_footer());
      return widgets;
    }

    final grouped = <Domain, List<Task>>{};
    for (final task in tasks) {
      grouped.putIfAbsent(task.domain, () => []).add(task);
    }

    final domains = Domain.values.where(grouped.containsKey).toList();

    for (final domain in domains) {
      final domainTasks = grouped[domain]!;
      widgets.addAll([
        _sectionLabel(domainLabel(domain)),
        pw.SizedBox(height: 8),
        _tasksBacklogTable(domainTasks),
        pw.SizedBox(height: 16),
      ]);
    }

    final completed =
        tasks.where((task) => task.status == TaskStatus.done).length;
    final inProgress =
        tasks.where((task) => task.status == TaskStatus.inProgress).length;
    final stuck =
        tasks.where((task) => task.status == TaskStatus.stuck).length;

    widgets.addAll([
      pw.Divider(color: _outline, thickness: 0.5),
      pw.SizedBox(height: 8),
      pw.Text(
        'Summary: ${tasks.length} total | $completed completed | '
        '$inProgress in progress | $stuck stuck',
        style: pw.TextStyle(
          font: _monoFont,
          fontSize: 9,
          color: _onSurfaceVariant,
        ),
      ),
      pw.SizedBox(height: 24),
      _footer(),
    ]);

    return widgets;
  }

  pw.Widget _tasksBacklogTable(List<Task> tasks) {
    final headerStyle = pw.TextStyle(
      font: _monoBold,
      fontSize: 8,
      color: _onSurface,
    );
    final cellStyle = pw.TextStyle(
      font: _bodyFont,
      fontSize: 9,
      color: _onSurface,
    );
    final dateFormat = DateFormat('MMM d, yyyy');

    return pw.Table(
      border: pw.TableBorder.all(color: _outline, width: 0.3),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.5),
        1: const pw.FlexColumnWidth(1.2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(0.7),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _surfaceHigh),
          children: [
            _tableCell('Task', headerStyle),
            _tableCell('Domain', headerStyle),
            _tableCell('Priority', headerStyle),
            _tableCell('Status', headerStyle),
            _tableCell('Deadline', headerStyle),
            _tableCell('Postponed', headerStyle),
          ],
        ),
        ...tasks.asMap().entries.map((entry) {
          final task = entry.value;
          final isOdd = entry.key.isOdd;
          final deadline = task.deadline == null
              ? '-'
              : dateFormat.format(task.deadline!);

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isOdd ? _surfaceLow : _bg,
            ),
            children: [
              _tableCell(task.title, cellStyle),
              _tableCell(domainLabel(task.domain), cellStyle),
              _tableCell(_priorityLabel(task.priority), cellStyle),
              _tableCell(_taskStatusLabel(task.status), cellStyle),
              _tableCell(deadline, cellStyle),
              _tableCell('${task.postponeCount}', cellStyle),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _sectionLabel(String text) {
    return pw.Text(
      _pdfText(text),
      style: pw.TextStyle(
        font: _monoBold,
        fontSize: 10,
        color: _onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }

  pw.Widget _bodyText(String text) {
    return pw.Text(
      _pdfText(text),
      style: pw.TextStyle(
        font: _bodyFont,
        fontSize: 11,
        color: _onSurface,
        lineSpacing: 4,
      ),
    );
  }

  pw.Widget _tableCell(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(_pdfText(text), style: style),
    );
  }

  String _weekLabel(DateTime weekOf) {
    return DateFormat('yyyy-MM-dd').format(weekOf);
  }

  String _sanitizeFilename(String label) {
    return label.replaceAll(RegExp(r'[^\w\-.]+'), '_').toLowerCase();
  }

  String _taskStatusLabel(TaskStatus status) {
    return switch (status) {
      TaskStatus.notStarted => 'Not Started',
      TaskStatus.inProgress => 'In Progress',
      TaskStatus.done => 'Done',
      TaskStatus.stuck => 'Stuck',
    };
  }

  String _priorityLabel(Priority priority) {
    return switch (priority) {
      Priority.low => 'LOW',
      Priority.medium => 'MEDIUM',
      Priority.high => 'HIGH',
      Priority.critical => 'CRITICAL',
    };
  }
}
