import 'package:sami_app/domain/entities/report_document.dart';
import 'package:sami_app/domain/repositories/reports_repository.dart';

class GetReportsUseCase {
  const GetReportsUseCase(this._repository);

  final ReportsRepository _repository;

  Future<List<ReportDocument>> call() => _repository.fetchReports();
}
