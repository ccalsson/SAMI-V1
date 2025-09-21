import 'package:equatable/equatable.dart';

class Company extends Equatable {
  const Company({
    required this.id,
    required this.name,
    this.logoPath,
  });

  final String id;
  final String name;
  final String? logoPath;

  Company copyWith({String? name, String? logoPath}) {
    return Company(
      id: id,
      name: name ?? this.name,
      logoPath: logoPath ?? this.logoPath,
    );
  }

  @override
  List<Object?> get props => [id, name, logoPath];
}
