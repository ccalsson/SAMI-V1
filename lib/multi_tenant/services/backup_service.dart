import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sami_app/multi_tenant/models/backup.dart';

class BackupService {
  BackupService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Uri _tenantUri(String tenantId, [String? path]) {
    final buffer = StringBuffer(baseUrl);
    if (!baseUrl.endsWith('/')) {
      buffer.write('/');
    }
    buffer
      ..write('tenants/')
      ..write(tenantId);
    if (path != null && path.isNotEmpty) {
      if (!path.startsWith('/')) {
        buffer.write('/');
      }
      buffer.write(path);
    }
    return Uri.parse(buffer.toString());
  }

  Future<Backup> createBackup({required String tenantId}) async {
    final response = await _client.post(_tenantUri(tenantId, 'backups'));
    if (response.statusCode >= 400) {
      throw BackupServiceException('Failed to create backup');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Backup.fromMap(data['id']?.toString() ?? '', data);
  }

  Future<List<Backup>> listBackups({required String tenantId}) async {
    final response = await _client.get(_tenantUri(tenantId, 'backups'));
    if (response.statusCode >= 400) {
      throw BackupServiceException('Failed to list backups');
    }
    final payload = jsonDecode(response.body);
    if (payload is List) {
      return payload
          .map((item) => Backup.fromMap(
                item['id']?.toString() ?? '',
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false);
    }
    if (payload is Map<String, dynamic> && payload['items'] is List) {
      final items = payload['items'] as List;
      return items
          .map((item) => Backup.fromMap(
                item['id']?.toString() ?? '',
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false);
    }
    return const <Backup>[];
  }

  Future<void> restore({
    required String tenantId,
    required String backupId,
  }) async {
    final response = await _client.post(
      _tenantUri(tenantId, 'backups/$backupId:restore'),
    );
    if (response.statusCode >= 400) {
      throw BackupServiceException('Failed to restore backup');
    }
  }

  void dispose() {
    _client.close();
  }
}

class BackupServiceException implements Exception {
  BackupServiceException(this.message);

  final String message;

  @override
  String toString() => 'BackupServiceException: $message';
}
