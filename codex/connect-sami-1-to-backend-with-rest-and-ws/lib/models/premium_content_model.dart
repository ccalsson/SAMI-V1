import 'package:cloud_firestore/cloud_firestore.dart';

class PremiumContent {
  final String id;
  final String title;
  final String description;
  final ContentType type;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final DateTime releaseDate;

  PremiumContent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.tags,
    required this.metadata,
    required this.releaseDate,
  });

  factory PremiumContent.fromMap(Map<String, dynamic> data) {
    return PremiumContent(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: ContentType.values.firstWhere((e) => e.toString() == data['type']),
      tags: List<String>.from(data['tags'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      releaseDate: (data['releaseDate'] as Timestamp).toDate(),
    );
  }
}

enum ContentType {
  guidedMeditation,
  masterclass,
  workshop,
  course,
  expertTalk,
} 