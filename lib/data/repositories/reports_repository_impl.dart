import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sami_app/data/models/report_model.dart';
import 'package:sami_app/data/sources/local/hive_local_storage.dart';
import 'package:sami_app/domain/entities/report_document.dart';
import 'package:sami_app/domain/repositories/reports_repository.dart';
import 'package:sami_app/shared/utils/file_writer.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(this._storage);

  final HiveLocalStorage _storage;

  @override
  Future<List<ReportDocument>> fetchReports() async {
    final reportsBox = _storage.box(HiveLocalStorage.reportsBox);
    return reportsBox.values
        .map(ReportModel.fromMap)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<String> generateReport(ReportDocument document) async {
    final reportsBox = _storage.box(HiveLocalStorage.reportsBox);
    final now = DateTime.now();
    final content = _buildMockContent(document, now);
    if (kIsWeb) {
      await reportsBox.put(
        'generated_${document.id}',
        <String, dynamic>{
          'content': content,
          'generatedAt': now.toIso8601String(),
          'format': document.format.name,
        },
      );
      return 'web_memory://${document.id}';
    }

    final directory = await getApplicationDocumentsDirectory();
    final extension = document.format == ReportFormat.csv ? 'csv' : 'json';
    final filename =
        'report_${document.id}_${now.millisecondsSinceEpoch}.$extension';
    final path = p.join(directory.path, filename);
    await writeStringToFile(path, content);
    await reportsBox.put(
      'generated_${document.id}',
      <String, dynamic>{
        'path': path,
        'generatedAt': now.toIso8601String(),
      },
    );
    return path;
  }

  String _buildMockContent(ReportDocument document, DateTime timestamp) {
    final data = <String, dynamic>{
      'id': document.id,
      'name': document.name,
      'description': document.description,
      'generatedAt': timestamp.toIso8601String(),
      'items': List.generate(5, (index) {
        return <String, dynamic>{
          'label': '${document.name} ${index + 1}',
          'value': (index + 1) * 12,
        };
      }),
    };
    if (document.format == ReportFormat.csv) {
      final buffer = StringBuffer('label,value\n');
      for (final item in data['items'] as List<dynamic>) {
        final map = item as Map<String, dynamic>;
        buffer.writeln('${map['label']},${map['value']}');
      }
      return buffer.toString();
    }
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
