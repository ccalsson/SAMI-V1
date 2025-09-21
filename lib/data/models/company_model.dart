import 'package:sami_app/domain/entities/company.dart';

class CompanyModel {
  const CompanyModel({
    required this.id,
    required this.name,
    this.logoPath,
  });

  final String id;
  final String name;
  final String? logoPath;

  factory CompanyModel.fromEntity(Company company) {
    return CompanyModel(
      id: company.id,
      name: company.name,
      logoPath: company.logoPath,
    );
  }

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      id: map['id'] as String,
      name: map['name'] as String,
      logoPath: map['logoPath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'logoPath': logoPath,
    };
  }

  Company toEntity() {
    return Company(
      id: id,
      name: name,
      logoPath: logoPath,
    );
  }
}
