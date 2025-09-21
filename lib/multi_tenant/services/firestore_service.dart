import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sami_app/multi_tenant/models/tenant_document.dart';

typedef TenantDocumentFactory<T extends TenantDocument> = T Function(
  String id,
  Map<String, dynamic> data,
);

class TenantMismatchException implements Exception {
  const TenantMismatchException(this.message);

  final String message;

  @override
  String toString() => 'TenantMismatchException: $message';
}

class DocumentNotFoundException implements Exception {
  const DocumentNotFoundException(this.message);

  final String message;

  @override
  String toString() => 'DocumentNotFoundException: $message';
}

class FirestoreService {
  FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<T>> list<T extends TenantDocument>({
    required String collectionPath,
    required String tenantId,
    required TenantDocumentFactory<T> fromDocument,
  }) async {
    final snapshot = await _firestore
        .collection(collectionPath)
        .where('tenantId', isEqualTo: tenantId)
        .get();
    return snapshot.docs
        .map((doc) => fromDocument(doc.id, doc.data()))
        .toList(growable: false);
  }

  Future<T?> get<T extends TenantDocument>({
    required String collectionPath,
    required String tenantId,
    required String id,
    required TenantDocumentFactory<T> fromDocument,
  }) async {
    final docRef = _firestore.collection(collectionPath).doc(id);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      return null;
    }
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    if (data['tenantId'] != tenantId) {
      throw TenantMismatchException(
          'Document $id does not belong to $tenantId');
    }
    return fromDocument(snapshot.id, data);
  }

  Future<String> create<T extends TenantDocument>({
    required String collectionPath,
    required String tenantId,
    required T data,
  }) async {
    if (data.tenantId != tenantId) {
      throw TenantMismatchException(
          'Payload tenantId mismatch for $collectionPath');
    }
    final collection = _firestore.collection(collectionPath);
    final docRef = data.id != null && data.id!.isNotEmpty
        ? collection.doc(data.id)
        : collection.doc();
    final payload = <String, dynamic>{
      ...data.toMap(),
      'tenantId': tenantId,
    };
    await docRef.set(payload);
    return docRef.id;
  }

  Future<void> update<T extends TenantDocument>({
    required String collectionPath,
    required String tenantId,
    required T data,
  }) async {
    final documentId = data.id;
    if (documentId == null || documentId.isEmpty) {
      throw ArgumentError('Update requires a document id');
    }
    if (data.tenantId != tenantId) {
      throw TenantMismatchException(
          'Payload tenantId mismatch for $collectionPath');
    }
    final docRef = _firestore.collection(collectionPath).doc(documentId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      throw DocumentNotFoundException('Document $documentId not found');
    }
    final current = snapshot.data();
    if (current == null || current['tenantId'] != tenantId) {
      throw TenantMismatchException(
          'Document $documentId does not belong to $tenantId');
    }
    final payload = <String, dynamic>{
      ...data.toMap(),
      'tenantId': tenantId,
    };
    await docRef.set(payload, SetOptions(merge: true));
  }

  Future<void> delete({
    required String collectionPath,
    required String tenantId,
    required String id,
  }) async {
    final docRef = _firestore.collection(collectionPath).doc(id);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      throw DocumentNotFoundException('Document $id not found');
    }
    final data = snapshot.data();
    if (data == null || data['tenantId'] != tenantId) {
      throw TenantMismatchException(
          'Document $id does not belong to $tenantId');
    }
    await docRef.delete();
  }
}
