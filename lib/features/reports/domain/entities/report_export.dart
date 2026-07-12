import 'revenue_summary.dart';

enum ReportExportFormat { pdf, excel }

class ReportExport {
  const ReportExport({
    required this.format,
    required this.fileName,
    required this.content,
  });

  final ReportExportFormat format;
  final String fileName;
  final String content;
}

class ReportExportRequest {
  const ReportExportRequest({required this.summary, required this.format});

  final RevenueSummary summary;
  final ReportExportFormat format;
}
