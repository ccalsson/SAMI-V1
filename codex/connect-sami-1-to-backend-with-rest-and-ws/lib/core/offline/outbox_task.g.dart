// GENERATED CODE - MANUALLY WRITTEN FOR OFFLINE SUPPORT
// ignore_for_file: public_member_api_docs

part of 'outbox_task.dart';

extension GetOutboxTaskCollection on Isar {
  IsarCollection<OutboxTask> get outboxTasks => collection<OutboxTask>();
}

const OutboxTaskSchema = CollectionSchema(
  name: r'OutboxTask',
  id: 6753342051123456789,
  properties: {
    r'method': PropertySchema(
      id: 0,
      name: r'method',
      type: IsarType.string,
    ),
    r'endpoint': PropertySchema(
      id: 1,
      name: r'endpoint',
      type: IsarType.string,
    ),
    r'payload': PropertySchema(
      id: 2,
      name: r'payload',
      type: IsarType.string,
    ),
    r'headers': PropertySchema(
      id: 3,
      name: r'headers',
      type: IsarType.string,
    ),
    r'reference': PropertySchema(
      id: 4,
      name: r'reference',
      type: IsarType.string,
    ),
    r'attempts': PropertySchema(
      id: 5,
      name: r'attempts',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 6,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'retryAt': PropertySchema(
      id: 7,
      name: r'retryAt',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 8,
      name: r'status',
      type: IsarType.byte,
      enumMap: {
        'pending': 0,
        'retrying': 1,
        'completed': 2,
        'failed': 3,
      },
    ),
  },
  estimateSize: _outboxTaskEstimateSize,
  serialize: _outboxTaskSerialize,
  deserialize: _outboxTaskDeserialize,
  deserializeProp: _outboxTaskDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _outboxTaskGetId,
  getLinks: _outboxTaskGetLinks,
  attach: _outboxTaskAttach,
  version: '3.1.0+1',
);

int _outboxTaskEstimateSize(
  OutboxTask object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.method.length * 3;
  bytesCount += 3 + object.endpoint.length * 3;
  bytesCount += 3 + object.payload.length * 3;
  final headers = object.headers;
  if (headers != null) {
    bytesCount += 3 + headers.length * 3;
  }
  final reference = object.reference;
  if (reference != null) {
    bytesCount += 3 + reference.length * 3;
  }
  return bytesCount;
}

void _outboxTaskSerialize(
  OutboxTask object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.method);
  writer.writeString(offsets[1], object.endpoint);
  writer.writeString(offsets[2], object.payload);
  writer.writeString(offsets[3], object.headers);
  writer.writeString(offsets[4], object.reference);
  writer.writeLong(offsets[5], object.attempts);
  writer.writeDateTime(offsets[6], object.createdAt);
  writer.writeDateTime(offsets[7], object.retryAt);
  writer.writeByte(offsets[8], object.status.index);
}

OutboxTask _outboxTaskDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OutboxTask();
  object.id = id;
  object.method = reader.readString(offsets[0]);
  object.endpoint = reader.readString(offsets[1]);
  object.payload = reader.readString(offsets[2]);
  object.headers = reader.readStringOrNull(offsets[3]);
  object.reference = reader.readStringOrNull(offsets[4]);
  object.attempts = reader.readLong(offsets[5]);
  object.createdAt = reader.readDateTime(offsets[6]);
  object.retryAt = reader.readDateTimeOrNull(offsets[7]);
  final statusIndex = reader.readByte(offsets[8]);
  object.status = OutboxStatus.values[statusIndex];
  return object;
}

P _outboxTaskDeserializeProp<P>(
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
      return reader.readStringOrNull(offset) as P;
    case 4:
      return reader.readStringOrNull(offset) as P;
    case 5:
      return reader.readLong(offset) as P;
    case 6:
      return reader.readDateTime(offset) as P;
    case 7:
      return reader.readDateTimeOrNull(offset) as P;
    case 8:
      return OutboxStatus.values[reader.readByte(offset)] as P;
    default:
      throw IsarError('Unknown property id');
  }
}

Id _outboxTaskGetId(OutboxTask object) => object.id;

List<IsarLinkBase<dynamic>> _outboxTaskGetLinks(OutboxTask object) => const [];

void _outboxTaskAttach(IsarCollection<dynamic> col, Id id, OutboxTask object) {
  object.id = id;
}
