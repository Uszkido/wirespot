import 'dart:typed_data';

import 'revenue_summary.dart';

enum ReportExportFormat { pdf, excel }

class ReportExport {
  const ReportExport({
    required this.format,
    required this.fileName,
    required this.content,
    required this.bytes,
  });

  final ReportExportFormat format;
  final String fileName;
  final String content;
  final Uint8List bytes;
}

class ReportExportRequest {
  const ReportExportRequest({required this.summary, required this.format});

  final RevenueSummary summary;
  final ReportExportFormat format;
}
