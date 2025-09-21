class Appointment {
  final String id;
  final String professionalId;
  final String patientId;
  final DateTime date;

  Appointment({required this.id, required this.professionalId, required this.patientId, required this.date});

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      professionalId: json['professionalId'],
      patientId: json['patientId'],
      date: DateTime.parse(json['date']),
    );
  }
}
