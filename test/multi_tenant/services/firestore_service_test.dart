import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sami_app/multi_tenant/models/tenant_document.dart';
import 'package:sami_app/multi_tenant/services/firestore_service.dart';

class _ExampleDoc extends TenantDocument {
  const _ExampleDoc({super.id, required super.tenantId, this.name = ''});

  final String name;

  @override
  Map<String, dynamic> toMap() => {'tenantId': tenantId, 'name': name};
}

_ExampleDoc _fromDocument(String id, Map<String, dynamic> data) {
  return _ExampleDoc(
    id: id,
    tenantId: data['tenantId'] as String,
    name: data['name'] as String? ?? '',
  );
}

void main() {
  group('FirestoreService with FakeFirebaseFirestore', () {
    const collectionPath = 'collection';
    const tenantId = 'tenant-a';

    late FakeFirebaseFirestore firestore;
    late FirestoreService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = FirestoreService(firestore);
    });

    test('list returns only documents for the requested tenant', () async {
      await firestore.collection(collectionPath).add({
        'tenantId': tenantId,
        'name': 'Primary',
      });
      await firestore.collection(collectionPath).add({
        'tenantId': 'tenant-b',
        'name': 'Other',
      });

      final docs = await service.list<_ExampleDoc>(
        collectionPath: collectionPath,
        tenantId: tenantId,
        fromDocument: _fromDocument,
      );

      expect(docs, hasLength(1));
      expect(docs.first.tenantId, tenantId);
      expect(docs.first.name, 'Primary');
    });

    test('get throws when tenantId mismatches', () async {
      final docRef = await firestore.collection(collectionPath).add({
        'tenantId': 'other-tenant',
        'name': 'Mismatch',
      });

      await expectLater(
        () => service.get<_ExampleDoc>(
          collectionPath: collectionPath,
          tenantId: tenantId,
          id: docRef.id,
          fromDocument: _fromDocument,
        ),
        throwsA(isA<TenantMismatchException>()),
      );
    });

    test('create enforces tenantId validation', () async {
      await expectLater(
        () => service.create<_ExampleDoc>(
          collectionPath: collectionPath,
          tenantId: tenantId,
          data: const _ExampleDoc(tenantId: 'other', name: 'X'),
        ),
        throwsA(isA<TenantMismatchException>()),
      );
    });

    test('update merges data when tenant matches', () async {
      final docRef = await firestore.collection(collectionPath).add({
        'tenantId': tenantId,
        'name': 'Original',
      });

      await service.update<_ExampleDoc>(
        collectionPath: collectionPath,
        tenantId: tenantId,
        data: _ExampleDoc(id: docRef.id, tenantId: tenantId, name: 'Updated'),
      );

      final snapshot =
          await firestore.collection(collectionPath).doc(docRef.id).get();
      expect(snapshot.data()?['name'], 'Updated');
    });

    test('delete removes document for matching tenant', () async {
      final docRef = await firestore.collection(collectionPath).add({
        'tenantId': tenantId,
        'name': 'ToDelete',
      });

      await service.delete(
        collectionPath: collectionPath,
        tenantId: tenantId,
        id: docRef.id,
      );

      final exists =
          (await firestore.collection(collectionPath).doc(docRef.id).get())
              .exists;
      expect(exists, isFalse);
    });
  });
}
