import 'package:sami_app/domain/entities/report_document.dart';

class ReportModel {
  const ReportModel({
    required this.id,
    required this.name,
    required this.description,
    required this.format,
  });

  final String id;
  final String name;
  final String description;
  final ReportFormat format;

  factory ReportModel.fromEntity(ReportDocument document) {
    return ReportModel(
      id: document.id,
      name: document.name,
      description: document.description,
      format: document.format,
    );
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      format: ReportFormat.values.firstWhere(
        (format) => format.name == map['format'],
        orElse: () => ReportFormat.csv,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'format': format.name,
    };
  }

  ReportDocument toEntity() {
    return ReportDocument(
      id: id,
      name: name,
      description: description,
      format: format,
    );
  }
}
