import 'package:cloud_functions/cloud_functions.dart';

/// Sends anonymized metrics to backend.
class MetricsSender {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> send(String event, Map<String, dynamic> data) async {
    await _functions.httpsCallable('anonymizeEvent').call({
      'event': event,
      'data': data,
    });
  }
}
