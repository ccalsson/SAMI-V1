class ActivityLog {
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  ActivityLog({
    required this.type,
    required this.timestamp,
    required this.data,
  });
}
