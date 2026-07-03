import 'dart:typed_data';

import 'package:printing/printing.dart';

Future<void> deliverExportFile({
  required Uint8List bytes,
  required String filename,
}) {
  return Printing.sharePdf(bytes: bytes, filename: filename);
}

Future<void> deliverPdf({
  required Uint8List bytes,
  required String filename,
}) {
  return deliverExportFile(bytes: bytes, filename: filename);
}
