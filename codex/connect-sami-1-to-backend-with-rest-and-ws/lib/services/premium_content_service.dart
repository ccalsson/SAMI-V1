import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/premium_content_model.dart';

class PremiumContentService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addPremiumContent(PremiumContent content) async {
    await _firestore.collection('premium_content').add({
      'title': content.title,
      'description': content.description,
      'type': content.type.toString(),
      'tags': content.tags,
      'metadata': content.metadata,
      'releaseDate': content.releaseDate.toIso8601String(),
    });
  }

  Stream<List<PremiumContent>> getPremiumContent() {
    return _firestore
        .collection('premium_content')
        .orderBy('releaseDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PremiumContent.fromMap(doc.data()))
            .toList());
  }
} 