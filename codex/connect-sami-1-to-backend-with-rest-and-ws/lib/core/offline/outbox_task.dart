import 'dart:convert';

import 'package:isar/isar.dart';

part 'outbox_task.g.dart';

enum OutboxStatus { pending, retrying, completed, failed }

@collection
class OutboxTask {
  OutboxTask();

  Id id = Isar.autoIncrement;

  String method = 'POST';
  String endpoint = '';
  String payload = '';
  String? headers;
  String? reference;
  int attempts = 0;

  DateTime createdAt = DateTime.now();
  DateTime? retryAt;

  @enumerated
  OutboxStatus status = OutboxStatus.pending;

  Map<String, dynamic> toJson() => {
        'method': method,
        'endpoint': endpoint,
        'payload': payload,
        'headers': headers,
        'reference': reference,
        'attempts': attempts,
        'createdAt': createdAt.toIso8601String(),
        'retryAt': retryAt?.toIso8601String(),
        'status': status.name,
      };

  static OutboxTask fromJson(Map<String, dynamic> json) {
    final task = OutboxTask();
    task.method = json['method'] as String? ?? 'POST';
    task.endpoint = json['endpoint'] as String? ?? '';
    task.payload = json['payload'] as String? ?? '';
    task.headers = json['headers'] as String?;
    task.reference = json['reference'] as String?;
    task.attempts = json['attempts'] as int? ?? 0;
    task.createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.now();
    task.retryAt = json['retryAt'] != null
        ? DateTime.tryParse(json['retryAt'] as String)
        : null;
    final status = json['status'] as String?;
    task.status = OutboxStatus.values.firstWhere(
      (value) => value.name == status,
      orElse: () => OutboxStatus.pending,
    );
    return task;
  }

  Map<String, String> decodedHeaders() {
    if (headers == null || headers!.isEmpty) {
      return <String, String>{};
    }
    try {
      final map = jsonDecode(headers!) as Map<String, dynamic>;
      return map.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
    } catch (_) {
      return <String, String>{};
    }
  }
}
