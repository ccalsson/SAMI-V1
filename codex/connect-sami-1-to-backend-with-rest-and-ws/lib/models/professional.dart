class Professional {
  final String id;
  final String name;
  final String specialty;

  Professional({required this.id, required this.name, required this.specialty});

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      id: json['id'],
      name: json['name'],
      specialty: json['specialty'],
    );
  }
}
