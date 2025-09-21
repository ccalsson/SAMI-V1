abstract class IAnalyticsService {
  Future<Map<String, dynamic>> getUserInsights(String userId);
}
