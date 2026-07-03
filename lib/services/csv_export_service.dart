import 'dart:convert';
import 'dart:typed_data';

import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/services/pdf_export_delivery.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:intl/intl.dart';

class CsvExportService {
  Future<void> exportTasks({
    required List<Task> tasks,
    required String periodLabel,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln(
      'Task,Domain,Priority,Status,Deadline,Postponed,Est Minutes,Focus Minutes,Accuracy',
    );

    final dateFormat = DateFormat('yyyy-MM-dd');
    for (final task in tasks) {
      buffer.writeln([
        _escape(task.title),
        domainLabel(task.domain),
        task.priority.name.toUpperCase(),
        task.status.name,
        task.deadline == null ? '' : dateFormat.format(task.deadline!),
        task.postponeCount,
        task.estimatedDurationMinutes ?? '',
        (task.totalFocusedSeconds / 60).round(),
        task.planningAccuracy == null
            ? ''
            : '${(task.planningAccuracy! * 100).round()}%',
      ].join(','));
    }

    final filename =
        'ciara_os_tasks_${_sanitizeFilename(periodLabel)}.csv';
    await deliverExportFile(
      bytes: Uint8List.fromList(utf8.encode(buffer.toString())),
      filename: filename,
    );
  }

  String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _sanitizeFilename(String label) {
    return label.replaceAll(RegExp(r'[^\w\-.]+'), '_').toLowerCase();
  }
}
