enum SessionStatus {
  scheduled,
  completed,
  cancelled,
  pending
}

class VirtualSession {
  final String id;
  final String userId;
  final String professionalId;
  final DateTime dateTime;
  final int duration; // en minutos
  final double price;
  final SessionStatus status;
  final bool isPremiumPromo;
  final String? notes;
  final String? meetingUrl;

  VirtualSession({
    required this.id,
    required this.userId,
    required this.professionalId,
    required this.dateTime,
    required this.duration,
    required this.price,
    required this.status,
    this.isPremiumPromo = false,
    this.notes,
    this.meetingUrl,
  });

  factory VirtualSession.fromMap(Map<String, dynamic> map) {
    return VirtualSession(
      id: map['id'],
      userId: map['userId'],
      professionalId: map['professionalId'],
      dateTime: DateTime.parse(map['dateTime']),
      duration: map['duration'],
      price: map['price'].toDouble(),
      status: SessionStatus.values.firstWhere(
        (e) => e.toString() == 'SessionStatus.${map["status"]}'
      ),
      isPremiumPromo: map['isPremiumPromo'] ?? false,
      notes: map['notes'],
      meetingUrl: map['meetingUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'professionalId': professionalId,
      'dateTime': dateTime.toIso8601String(),
      'duration': duration,
      'price': price,
      'status': status.toString().split('.').last,
      'isPremiumPromo': isPremiumPromo,
      'notes': notes,
      'meetingUrl': meetingUrl,
    };
  }
} 