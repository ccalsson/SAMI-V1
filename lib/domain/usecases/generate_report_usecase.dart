import 'package:sami_app/domain/entities/report_document.dart';
import 'package:sami_app/domain/repositories/reports_repository.dart';

class GenerateReportUseCase {
  const GenerateReportUseCase(this._repository);

  final ReportsRepository _repository;

  Future<String> call(ReportDocument document) =>
      _repository.generateReport(document);
}
