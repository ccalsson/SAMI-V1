abstract class ReportsRepository {
  Future<String> downloadAlertsReport({required DateTime from, required DateTime to});

  Future<String> downloadFuelReport({required DateTime from, required DateTime to});

  Future<String> downloadToolsReport({required DateTime from, required DateTime to});
}
