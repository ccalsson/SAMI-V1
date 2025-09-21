class Patient {
  final String id;
  final String name;
  final String email;

  Patient({required this.id, required this.name, required this.email});

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
