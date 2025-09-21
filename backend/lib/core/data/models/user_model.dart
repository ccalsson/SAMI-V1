import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String country;
  final String region; // latam, na, eu
  final bool studentFlag;
  final List<String> preferredModules;
  final bool guardianConsent;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.country,
    required this.region,
    this.studentFlag = false,
    this.preferredModules = const [],
    this.guardianConsent = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      country: data['country'] ?? 'AR',
      region: data['region'] ?? 'latam',
      studentFlag: data['studentFlag'] ?? false,
      preferredModules: List<String>.from(data['preferredModules'] ?? []),
      guardianConsent: data['guardianConsent'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'country': country,
      'region': region,
      'studentFlag': studentFlag,
      'preferredModules': preferredModules,
      'guardianConsent': guardianConsent,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? country,
    String? region,
    bool? studentFlag,
    List<String>? preferredModules,
    bool? guardianConsent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      country: country ?? this.country,
      region: region ?? this.region,
      studentFlag: studentFlag ?? this.studentFlag,
      preferredModules: preferredModules ?? this.preferredModules,
      guardianConsent: guardianConsent ?? this.guardianConsent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
