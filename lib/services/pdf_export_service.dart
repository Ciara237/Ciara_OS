import 'package:ciaraos/models/focus_session_record.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/models/weekly_review.dart';
import 'package:ciaraos/services/pdf/pdf_tokens.dart';
import 'package:ciaraos/services/pdf/task_export_pdf_template.dart';
import 'package:ciaraos/services/pdf/weekly_debrief_pdf_template.dart';
import 'package:ciaraos/services/pdf_export_delivery.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

typedef FocusSession = FocusSessionRecord;

class PdfExportService {
  final _weeklyTemplate = WeeklyDebriefPdfTemplate();
  final _taskTemplate = TaskExportPdfTemplate();

  Future<void> exportWeeklyReview({
    required WeeklyReview review,
    required List<Task> tasksThisWeek,
    required List<FocusSession> sessionsThisWeek,
  }) async {
    final pdf = pw.Document(
      title: 'Ciara OS Weekly Review',
      creator: 'Ciara OS',
    );

    for (final page in _weeklyTemplate.buildPages(
      review: review,
      tasksThisWeek: tasksThisWeek,
      sessionsThisWeek: sessionsThisWeek,
    )) {
      pdf.addPage(page);
    }

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
        pageTheme: PdfTokens.lightPageTheme(),
        build: (context) => _taskTemplate.buildContent(
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

  String _weekLabel(DateTime weekOf) {
    return DateFormat('yyyy-MM-dd').format(weekOf);
  }

  String _sanitizeFilename(String label) {
    return label.replaceAll(RegExp(r'[^\w\-.]+'), '_').toLowerCase();
  }
}
