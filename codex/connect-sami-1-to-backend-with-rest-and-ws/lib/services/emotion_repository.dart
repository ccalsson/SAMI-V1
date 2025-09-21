import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../security/client_crypto.dart';

/// Repository for emotion entries that encrypts data client-side using
/// [ClientCrypto]. This is a minimal example; production code would handle
/// errors and key rotation.
class EmotionRepository {
  final FirebaseFirestore _db;
  final ClientCrypto _crypto;

  EmotionRepository(this._db, this._crypto);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('emotions').doc(uid).collection('entries');

  Future<void> addEntry(String uid, Map<String, dynamic> data) async {
    final payload = await _crypto.encrypt(jsonEncode(data));
    await _col(uid).add({'payload': payload});
  }

  Future<Map<String, dynamic>> getEntry(String uid, String id) async {
    final snap = await _col(uid).doc(id).get();
    final decrypted = await _crypto.decrypt(snap['payload'] as String);
    return jsonDecode(decrypted) as Map<String, dynamic>;
  }
}
