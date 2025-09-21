import 'dart:convert';

import 'package:isar/isar.dart';

part 'entities.g.dart';

@collection
class CachedEntity {
  CachedEntity();

  CachedEntity.create({
    required this.type,
    required this.entityId,
    required this.data,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now() {
    key = '${type}_$entityId';
  }

  Id id = Isar.autoIncrement;

  String key = '';

  String type = '';

  String entityId = '';

  String data = '';
  DateTime? updatedAt;

  Map<String, dynamic> toMap() => {
        'type': type,
        'entityId': entityId,
        'data': data,
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static CachedEntity fromMap(Map<String, dynamic> map) => CachedEntity.create(
        type: map['type'] as String,
        entityId: map['entityId'] as String,
        data: map['data'] as String,
        updatedAt: map['updatedAt'] != null
            ? DateTime.tryParse(map['updatedAt'] as String)
            : null,
      );
}

extension CachedEntityJson on CachedEntity {
  Map<String, dynamic> decodeJson() => jsonDecode(data) as Map<String, dynamic>;
}
