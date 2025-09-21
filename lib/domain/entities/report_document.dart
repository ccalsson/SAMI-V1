import 'package:equatable/equatable.dart';

enum ReportFormat { csv, json }

class ReportDocument extends Equatable {
  const ReportDocument({
    required this.id,
    required this.name,
    required this.description,
    required this.format,
  });

  final String id;
  final String name;
  final String description;
  final ReportFormat format;

  @override
  List<Object?> get props => [id, name, description, format];
}
