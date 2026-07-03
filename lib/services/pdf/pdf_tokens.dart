import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// TODO: embed Inter + JetBrains Mono TTF files in Phase 2 for brand-accurate PDF typography

/// Shared PDF typography and palette tokens (Stitch weekly debrief + task export).
abstract final class PdfTokens {
  static final bodyFont = pw.Font.helvetica();
  static final monoFont = pw.Font.courier();
  static final bodyBold = pw.Font.helveticaBold();
  static final monoBold = pw.Font.courierBold();

  // Dark theme — weekly_executive_debrief_template
  static const darkBg = PdfColor.fromInt(0xFF081425);
  static const darkOnSurface = PdfColor.fromInt(0xFFD8E3FB);
  static const darkOnSurfaceMuted = PdfColor.fromInt(0xFF8E9197);
  static const darkOnSurfaceVariant = PdfColor.fromInt(0xFFC5C6CD);
  static const darkPrimary = PdfColor.fromInt(0xFFB9C7E0);
  static const darkSurfaceCard = PdfColor.fromInt(0xFF111C2D);
  static const darkSurfaceElevated = PdfColor.fromInt(0xFF152031);
  static const darkSurfaceRowAlt = PdfColor.fromInt(0xFF0D1829);
  static const darkDivider = PdfColor.fromInt(0xFF2A3548);
  static const darkFooter = PdfColor.fromInt(0xFF44474C);

  // Light theme — task_export_template_light_professional
  static const lightBg = PdfColor.fromInt(0xFFFFFFFF);
  static const lightOnSurface = PdfColor.fromInt(0xFF0F172A);
  static const lightMuted = PdfColor.fromInt(0xFF64748B);
  static const lightSummaryBg = PdfColor.fromInt(0xFFF1F5F9);
  static const lightSummaryBorder = PdfColor.fromInt(0xFFE2E8F0);
  static const lightDomainHeaderBg = PdfColor.fromInt(0xFFF8FAFC);
  static const lightRowAlt = PdfColor.fromInt(0xFFF8FAFC);
  static const lightDivider = PdfColor.fromInt(0xFFE2E8F0);

  // Semantic accents (Stitch domain + status colors)
  static const green = PdfColor.fromInt(0xFF10B981);
  static const red = PdfColor.fromInt(0xFFEF4444);
  static const blue = PdfColor.fromInt(0xFF3B82F6);
  static const amber = PdfColor.fromInt(0xFFF59E0B);
  static const purple = PdfColor.fromInt(0xFF8B5CF6);
  static const slate = PdfColor.fromInt(0xFF64748B);

  static const Map<Domain, PdfColor> domainAccent = {
    Domain.engineering: blue,
    Domain.security: red,
    Domain.opportunities: green,
    Domain.builder: purple,
    Domain.other: slate,
  };

  /// Built-in PDF fonts (Helvetica/Courier) are Latin-1 only.
  static String sanitize(String text) {
    return text
        .replaceAll('\u2014', '-')
        .replaceAll('\u2013', '-')
        .replaceAll('\u2022', '*')
        .replaceAll('\u00B7', ' | ')
        .replaceAll('\u25A1', '[]')
        .replaceAll('\u25B8', '>');
  }

  static PdfColor domainColor(Domain domain) =>
      domainAccent[domain] ?? slate;

  static PdfColor priorityColor(Priority priority) {
    return switch (priority) {
      Priority.low => slate,
      Priority.medium => blue,
      Priority.high => amber,
      Priority.critical => red,
    };
  }

  static PdfColor statusColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.done => green,
      TaskStatus.inProgress => blue,
      TaskStatus.stuck => red,
      TaskStatus.notStarted => lightMuted,
    };
  }

  static String statusLabel(TaskStatus status) {
    return switch (status) {
      TaskStatus.notStarted => 'NOT STARTED',
      TaskStatus.inProgress => 'IN PROGRESS',
      TaskStatus.done => 'DONE',
      TaskStatus.stuck => 'STUCK',
    };
  }

  static String priorityLabel(Priority priority) {
    return switch (priority) {
      Priority.low => 'LOW',
      Priority.medium => 'MEDIUM',
      Priority.high => 'HIGH',
      Priority.critical => 'CRITICAL',
    };
  }

  static pw.PageTheme darkPageTheme() {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(56),
      theme: pw.ThemeData.withFont(base: bodyFont, bold: bodyBold),
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Container(color: darkBg),
      ),
    );
  }

  static pw.PageTheme lightPageTheme() {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(56),
      theme: pw.ThemeData.withFont(base: bodyFont, bold: bodyBold),
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Container(color: lightBg),
      ),
    );
  }
}
