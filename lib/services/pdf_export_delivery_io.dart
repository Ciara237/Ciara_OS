import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

Future<void> deliverPdf({
  required Uint8List bytes,
  required String filename,
}) async {
  try {
    await Printing.sharePdf(bytes: bytes, filename: filename);
    return;
  } on MissingPluginException {
    // Hot restart does not register native plugins — save locally instead.
  }

  final dir =
      await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  final path = '${dir.path}/$filename';
  final file = File(path);
  await file.writeAsBytes(bytes, flush: true);

  if (Platform.isLinux) {
    await Process.run('xdg-open', [path]);
  } else if (Platform.isMacOS) {
    await Process.run('open', [path]);
  } else if (Platform.isWindows) {
    await Process.run('cmd', ['/c', 'start', '', path]);
  }
}
