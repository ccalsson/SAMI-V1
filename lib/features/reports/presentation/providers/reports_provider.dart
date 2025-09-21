import 'package:flutter/foundation.dart';
import 'package:sami_app/domain/entities/report_document.dart';
import 'package:sami_app/domain/usecases/generate_report_usecase.dart';
import 'package:sami_app/domain/usecases/get_reports_usecase.dart';

class ReportsProvider extends ChangeNotifier {
  ReportsProvider({
    required GetReportsUseCase getReports,
    required GenerateReportUseCase generateReport,
  })  : _getReports = getReports,
        _generateReport = generateReport;

  final GetReportsUseCase _getReports;
  final GenerateReportUseCase _generateReport;

  List<ReportDocument> _reports = <ReportDocument>[];
  bool _loading = false;
  bool _generating = false;
  String? _lastGeneratedPath;

  List<ReportDocument> get reports => _reports;
  bool get isLoading => _loading;
  bool get isGenerating => _generating;
  String? get lastGeneratedPath => _lastGeneratedPath;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _reports = await _getReports();
    _loading = false;
    notifyListeners();
  }

  Future<void> generate(ReportDocument document) async {
    _generating = true;
    notifyListeners();
    _lastGeneratedPath = await _generateReport(document);
    _generating = false;
    notifyListeners();
  }
}
