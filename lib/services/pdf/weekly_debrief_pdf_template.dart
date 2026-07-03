import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/focus_session_record.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/models/weekly_review.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:ciaraos/services/pdf/pdf_tokens.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/utils/review_stats_utils.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Stitch `weekly_executive_debrief_template` — dark premium PDF layout.
class WeeklyDebriefPdfTemplate {
  List<pw.Page> buildPages({
    required WeeklyReview review,
    required List<Task> tasksThisWeek,
    required List<FocusSessionRecord> sessionsThisWeek,
  }) {
    return [
      _executivePage(review: review, sessions: sessionsThisWeek),
      _taskBreakdownPage(review.weekOf, tasksThisWeek),
      _prioritiesPage(review),
    ];
  }

  pw.Page _executivePage({
    required WeeklyReview review,
    required List<FocusSessionRecord> sessions,
  }) {
    final score = (review.executionScore ?? review.focusScore ?? 0).round();
    final startedPercent = review.startedRate == null
        ? '-'
        : '${(review.startedRate! * 100).round()}%';
    final focusSeconds = sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationSeconds,
    );
    final focusLabel = formatFocusUptime(focusSeconds);

    return pw.Page(
      pageTheme: PdfTokens.darkPageTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _darkHeader(review.weekOf),
          pw.SizedBox(height: 28),
          pw.Row(
            children: [
              pw.Expanded(child: _scoreTile('$score', '/100', 'EXECUTION SCORE')),
              pw.SizedBox(width: 16),
              pw.Expanded(child: _scoreTile(startedPercent, null, 'STARTED RATE')),
              pw.SizedBox(width: 16),
              pw.Expanded(child: _scoreTile(focusLabel, null, 'FOCUS HOURS')),
            ],
          ),
          pw.SizedBox(height: 28),
          _monoLabel('WEEKLY NARRATIVE'),
          pw.SizedBox(height: 10),
          _surfaceCard(
            review.weeklyNarrative ?? 'No narrative recorded.',
            PdfTokens.darkOnSurfaceVariant,
          ),
          pw.SizedBox(height: 16),
          _reflectionCard(
            label: 'WHAT WORKED',
            body: review.whatWorked ?? '-',
            accent: PdfTokens.green,
          ),
          pw.SizedBox(height: 10),
          _reflectionCard(
            label: 'WHAT FAILED',
            body: review.whatSlowedDown ?? '-',
            accent: PdfTokens.red,
          ),
          pw.SizedBox(height: 10),
          _reflectionCard(
            label: 'IMPROVEMENT',
            body: review.improvementForNextWeek ?? '-',
            accent: PdfTokens.blue,
          ),
          pw.Spacer(),
          _darkFooter(),
        ],
      ),
    );
  }

  pw.Page _taskBreakdownPage(DateTime weekOf, List<Task> tasks) {
    return pw.Page(
      pageTheme: PdfTokens.darkPageTheme(),
      build: (context) {
        if (tasks.isEmpty) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _darkHeader(weekOf),
              pw.SizedBox(height: 20),
              _monoLabel('TASK BREAKDOWN THIS WEEK'),
              pw.SizedBox(height: 12),
              _bodyText('No tasks recorded for this week.', PdfTokens.darkOnSurfaceVariant),
              pw.Spacer(),
              _darkFooter(),
            ],
          );
        }

        final grouped = <Domain, List<Task>>{};
        for (final task in tasks) {
          grouped.putIfAbsent(task.domain, () => []).add(task);
        }
        final domains = Domain.values.where(grouped.containsKey).toList();

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _darkHeader(weekOf),
            pw.SizedBox(height: 20),
            _monoLabel('TASK BREAKDOWN THIS WEEK'),
            pw.SizedBox(height: 14),
            ...domains.expand((domain) {
              final domainTasks = grouped[domain]!;
              final accent = PdfTokens.domainColor(domain);
              return [
                _domainHeader(domainLabel(domain), domainTasks.length, accent),
                pw.SizedBox(height: 6),
                _domainTaskTable(domainTasks, accent),
                pw.SizedBox(height: 14),
              ];
            }),
            pw.Spacer(),
            _darkFooter(),
          ],
        );
      },
    );
  }

  pw.Page _prioritiesPage(WeeklyReview review) {
    final actions = review.nextActions;

    return pw.Page(
      pageTheme: PdfTokens.darkPageTheme(),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _darkHeader(review.weekOf),
          pw.SizedBox(height: 20),
          _monoLabel('NEXT WEEK PRIORITIES'),
          pw.SizedBox(height: 14),
          if (actions.isEmpty)
            _bodyText('No next actions recorded.', PdfTokens.darkOnSurfaceVariant)
          else
            ...actions.map(
              (action) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '*',
                      style: pw.TextStyle(
                        font: PdfTokens.bodyFont,
                        fontSize: 11,
                        color: PdfTokens.darkPrimary,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: _bodyText(action, PdfTokens.darkOnSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          pw.Spacer(),
          _darkFooter(),
        ],
      ),
    );
  }

  pw.Widget _darkHeader(DateTime weekOf) {
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
                color: PdfTokens.darkOnSurface,
              ),
            ),
            pw.Text(
              'Weekly Executive Debrief',
              style: pw.TextStyle(
                font: PdfTokens.bodyFont,
                fontSize: 11,
                color: PdfTokens.darkOnSurfaceMuted,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(height: 1, color: PdfTokens.darkDivider),
        pw.SizedBox(height: 10),
        pw.Text(
          PdfTokens.sanitize(reviewWeekRangeLabel(weekOf)),
          style: pw.TextStyle(
            font: PdfTokens.monoFont,
            fontSize: 10,
            color: PdfTokens.darkOnSurfaceMuted,
          ),
        ),
      ],
    );
  }

  pw.Widget _scoreTile(String value, String? suffix, String label) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: pw.BoxDecoration(
        color: PdfTokens.darkSurfaceElevated,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: PdfTokens.sanitize(value),
                  style: pw.TextStyle(
                    font: PdfTokens.bodyBold,
                    fontSize: 28,
                    color: PdfTokens.darkOnSurface,
                  ),
                ),
                if (suffix != null)
                  pw.TextSpan(
                    text: PdfTokens.sanitize(suffix),
                    style: pw.TextStyle(
                      font: PdfTokens.bodyFont,
                      fontSize: 14,
                      color: PdfTokens.darkOnSurfaceMuted,
                    ),
                  ),
              ],
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            PdfTokens.sanitize(label),
            style: pw.TextStyle(
              font: PdfTokens.monoFont,
              fontSize: 8,
              color: PdfTokens.darkOnSurfaceMuted,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  pw.Widget _monoLabel(String text) {
    return pw.Text(
      PdfTokens.sanitize(text),
      style: pw.TextStyle(
        font: PdfTokens.monoBold,
        fontSize: 9,
        color: PdfTokens.darkOnSurfaceMuted,
        letterSpacing: 1,
      ),
    );
  }

  pw.Widget _surfaceCard(String text, PdfColor color) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfTokens.darkSurfaceCard,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        PdfTokens.sanitize(text),
        style: pw.TextStyle(
          font: PdfTokens.bodyFont,
          fontSize: 11,
          color: color,
          lineSpacing: 4,
        ),
      ),
    );
  }

  pw.Widget _reflectionCard({
    required String label,
    required String body,
    required PdfColor accent,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfTokens.darkSurfaceCard,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border(left: pw.BorderSide(color: accent, width: 4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            PdfTokens.sanitize(label),
            style: pw.TextStyle(
              font: PdfTokens.monoBold,
              fontSize: 9,
              color: accent,
            ),
          ),
          pw.SizedBox(height: 6),
          _bodyText(body, PdfTokens.darkOnSurfaceVariant),
        ],
      ),
    );
  }

  pw.Widget _domainHeader(String domain, int count, PdfColor accent) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfTokens.darkSurfaceElevated,
        border: pw.Border(left: pw.BorderSide(color: accent, width: 4)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            PdfTokens.sanitize(domain),
            style: pw.TextStyle(
              font: PdfTokens.monoBold,
              fontSize: 10,
              color: accent,
            ),
          ),
          pw.Text(
            '$count TASKS',
            style: pw.TextStyle(
              font: PdfTokens.monoFont,
              fontSize: 9,
              color: PdfTokens.darkOnSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _domainTaskTable(List<Task> tasks, PdfColor accent) {
    final headerStyle = pw.TextStyle(
      font: PdfTokens.monoBold,
      fontSize: 8,
      color: PdfTokens.darkOnSurfaceMuted,
    );

    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1.2),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfTokens.darkSurfaceCard),
          children: [
            _headerCell('TASK', headerStyle),
            _headerCell('PRIORITY', headerStyle),
            _headerCell('STATUS', headerStyle),
            _headerCell('ACCURACY', headerStyle),
          ],
        ),
        ...tasks.asMap().entries.map((entry) {
          final task = entry.value;
          final bg = entry.key.isOdd
              ? PdfTokens.darkSurfaceCard
              : PdfTokens.darkSurfaceRowAlt;
          final priorityColor = PdfTokens.priorityColor(task.priority);
          final statusColor = PdfTokens.statusColor(task.status);
          final accuracy = formatPlanningAccuracy(task.planningAccuracy);
          final accuracyColor = task.planningAccuracy == null
              ? PdfTokens.darkOnSurfaceMuted
              : (task.planningAccuracy! >= 0.85
                  ? PdfTokens.green
                  : (task.planningAccuracy! >= 0.7
                      ? PdfTokens.amber
                      : PdfTokens.red));

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: bg,
              border: pw.Border(left: pw.BorderSide(color: accent, width: 1)),
            ),
            children: [
              _dataCell(task.title, PdfTokens.darkOnSurfaceVariant),
              _dataCell(
                PdfTokens.priorityLabel(task.priority),
                priorityColor,
              ),
              _dataCell(PdfTokens.statusLabel(task.status), statusColor),
              _dataCell(accuracy, accuracyColor),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _headerCell(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(PdfTokens.sanitize(text), style: style),
    );
  }

  pw.Widget _dataCell(String text, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        PdfTokens.sanitize(text),
        style: pw.TextStyle(
          font: PdfTokens.bodyFont,
          fontSize: 9,
          color: color,
        ),
      ),
    );
  }

  pw.Widget _bodyText(String text, PdfColor color) {
    return pw.Text(
      PdfTokens.sanitize(text),
      style: pw.TextStyle(
        font: PdfTokens.bodyFont,
        fontSize: 10,
        color: color,
        lineSpacing: 3,
      ),
    );
  }

  pw.Widget _darkFooter() {
    final generated = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return pw.Column(
      children: [
        pw.Container(height: 1, color: PdfTokens.darkDivider),
        pw.SizedBox(height: 10),
        pw.Text(
          'CIARA OS v1.0.0 | Generated $generated | Private & confidential',
          style: pw.TextStyle(
            font: PdfTokens.monoFont,
            fontSize: 8,
            color: PdfTokens.darkFooter,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}
