// GENERATED CODE - MANUALLY WRITTEN FOR OFFLINE SUPPORT
// ignore_for_file: public_member_api_docs

part of 'entities.dart';

extension GetCachedEntityCollection on Isar {
  IsarCollection<CachedEntity> get cachedEntitys => collection<CachedEntity>();
}

const CachedEntitySchema = CollectionSchema(
  name: r'CachedEntity',
  id: 7936123458123456789,
  properties: {
    r'key': PropertySchema(
      id: 0,
      name: r'key',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 1,
      name: r'type',
      type: IsarType.string,
    ),
    r'entityId': PropertySchema(
      id: 2,
      name: r'entityId',
      type: IsarType.string,
    ),
    r'data': PropertySchema(
      id: 3,
      name: r'data',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 4,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _cachedEntityEstimateSize,
  serialize: _cachedEntitySerialize,
  deserialize: _cachedEntityDeserialize,
  deserializeProp: _cachedEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _cachedEntityGetId,
  getLinks: _cachedEntityGetLinks,
  attach: _cachedEntityAttach,
  version: '3.1.0+1',
);

int _cachedEntityEstimateSize(
  CachedEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.type.length * 3;
  bytesCount += 3 + object.entityId.length * 3;
  bytesCount += 3 + object.data.length * 3;
  return bytesCount;
}

void _cachedEntitySerialize(
  CachedEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.key);
  writer.writeString(offsets[1], object.type);
  writer.writeString(offsets[2], object.entityId);
  writer.writeString(offsets[3], object.data);
  writer.writeDateTime(offsets[4], object.updatedAt);
}

CachedEntity _cachedEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CachedEntity();
  object.id = id;
  object.key = reader.readString(offsets[0]);
  object.type = reader.readString(offsets[1]);
  object.entityId = reader.readString(offsets[2]);
  object.data = reader.readString(offsets[3]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[4]);
  return object;
}

P _cachedEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return reader.readString(offset) as P;
    case 1:
      return reader.readString(offset) as P;
    case 2:
      return reader.readString(offset) as P;
    case 3:
      return reader.readString(offset) as P;
    case 4:
      return reader.readDateTimeOrNull(offset) as P;
    default:
      throw IsarError('Unknown property id');
  }
}

Id _cachedEntityGetId(CachedEntity object) => object.id;

List<IsarLinkBase<dynamic>> _cachedEntityGetLinks(CachedEntity object) => const [];

void _cachedEntityAttach(
    IsarCollection<dynamic> col, Id id, CachedEntity object) {
  object.id = id;
}
