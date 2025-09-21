import '../models/activity_log.dart';

abstract class IDataRepository {
  Future<List<ActivityLog>> getUserHistory(String userId);
}
