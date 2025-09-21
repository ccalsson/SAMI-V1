import 'dart:convert';

import 'package:isar/isar.dart';

import 'entities.dart';

class CacheStore {
  CacheStore(this._isar);

  final Isar _isar;

  Future<void> saveAll(String type, List<Map<String, dynamic>> items) async {
    await _isar.writeTxn(() async {
      final query = _isar.cachedEntitys.buildQuery<CachedEntity>();
      final existing = await query.findAll();
      for (final entity in existing.where((element) => element.type == type)) {
        await _isar.cachedEntitys.delete(entity.id);
      }
      for (final item in items) {
        final entity = CachedEntity.create(
          type: type,
          entityId: item['id'].toString(),
          data: jsonEncode(item),
        );
        await _isar.cachedEntitys.put(entity);
      }
    });
  }

  Future<void> saveOne(String type, String id, Map<String, dynamic> data) async {
    await _isar.writeTxn(() async {
      final entity = CachedEntity.create(
        type: type,
        entityId: id,
        data: jsonEncode(data),
      );
      await _isar.cachedEntitys.put(entity);
    });
  }

  Future<List<Map<String, dynamic>>> readAll(String type) async {
    final query = _isar.cachedEntitys.buildQuery<CachedEntity>();
    final items = await query.findAll();
    return items
        .where((element) => element.type == type)
        .map((entity) => jsonDecode(entity.data) as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>?> readOne(String type, String id) async {
    final query = _isar.cachedEntitys.buildQuery<CachedEntity>();
    final items = await query.findAll();
    final entity = items.firstWhere(
      (element) => element.type == type && element.entityId == id,
      orElse: () => CachedEntity.create(type: '', entityId: '', data: '{}'),
    );
    if (entity.type.isEmpty) {
      return null;
    }
    return jsonDecode(entity.data) as Map<String, dynamic>;
  }
}
