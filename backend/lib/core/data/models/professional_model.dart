class ProfessionalModel {
  final String uid;
  final String name;
  final String licenseNumber;
  final String licenseCountry;
  final bool verified;
  final String? verifiedBy;
  final List<String> specialties;
  final List<String> languages;
  final String rateCurrency;
  final double rateAmount;
  final String country;
  final String city;
  final bool telehealth;
  final String bio;
  final double rating;
  final DateTime createdAt;

  ProfessionalModel({
    required this.uid,
    required this.name,
    required this.licenseNumber,
    required this.licenseCountry,
    this.verified = false,
    this.verifiedBy,
    required this.specialties,
    required this.languages,
    required this.rateCurrency,
    required this.rateAmount,
    required this.country,
    required this.city,
    this.telehealth = true,
    required this.bio,
    this.rating = 0.0,
    required this.createdAt,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      licenseCountry: json['license_country'] ?? '',
      verified: json['verified'] ?? false,
      verifiedBy: json['verified_by'],
      specialties: List<String>.from(json['specialties'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      rateCurrency: json['rate_currency'] ?? 'USD',
      rateAmount: (json['rate_amount'] ?? 0.0).toDouble(),
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      telehealth: json['telehealth'] ?? true,
      bio: json['bio'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'license_number': licenseNumber,
      'license_country': licenseCountry,
      'verified': verified,
      'verified_by': verifiedBy,
      'specialties': specialties,
      'languages': languages,
      'rate_currency': rateCurrency,
      'rate_amount': rateAmount,
      'country': country,
      'city': city,
      'telehealth': telehealth,
      'bio': bio,
      'rating': rating,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
