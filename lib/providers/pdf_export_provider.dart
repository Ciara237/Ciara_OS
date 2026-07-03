import 'package:ciaraos/services/pdf_export_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pdfExportServiceProvider = Provider<PdfExportService>((ref) {
  return PdfExportService();
});
