import 'package:ciaraos/services/csv_export_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final csvExportServiceProvider = Provider<CsvExportService>((ref) {
  return CsvExportService();
});
