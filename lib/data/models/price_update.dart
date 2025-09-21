import 'package:hive/hive.dart';

class PriceUpdate extends HiveObject {
  PriceUpdate({
    required this.productId,
    required this.oldPrice,
    required this.newPrice,
    required this.timestamp,
    required this.source,
  });

  final String productId;
  final double oldPrice;
  final double newPrice;
  final DateTime timestamp;
  final String source; // voice | manual

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'oldPrice': oldPrice,
        'newPrice': newPrice,
        'timestamp': timestamp.toIso8601String(),
        'source': source,
      };

  factory PriceUpdate.fromJson(Map<String, dynamic> json) {
    return PriceUpdate(
      productId: json['productId'] as String,
      oldPrice: (json['oldPrice'] as num).toDouble(),
      newPrice: (json['newPrice'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: json['source'] as String,
    );
  }
}

class PriceUpdateAdapter extends TypeAdapter<PriceUpdate> {
  @override
  final int typeId = 205;

  @override
  PriceUpdate read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < count; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return PriceUpdate(
      productId: fields[0] as String,
      oldPrice: fields[1] as double,
      newPrice: fields[2] as double,
      timestamp: DateTime.fromMillisecondsSinceEpoch(fields[3] as int),
      source: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PriceUpdate obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.oldPrice)
      ..writeByte(2)
      ..write(obj.newPrice)
      ..writeByte(3)
      ..write(obj.timestamp.millisecondsSinceEpoch)
      ..writeByte(4)
      ..write(obj.source);
  }
}
