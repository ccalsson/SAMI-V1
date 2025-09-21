import 'package:sami_app/domain/entities/report_document.dart';

abstract class ReportsRepository {
  Future<List<ReportDocument>> fetchReports();
  Future<String> generateReport(ReportDocument document);
}
