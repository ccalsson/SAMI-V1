import 'package:hive/hive.dart';
import 'sale_item.dart';

class Sale extends HiveObject {
  Sale({
    required this.id,
    required this.timestamp,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paymentMethod,
  });

  final String id;
  final DateTime timestamp;
  final List<SaleItem> items;
  final double subtotal;
  final double discount;
  final double total;
  final String paymentMethod;

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'items': items.map((item) => item.toJson()).toList(),
        'subtotal': subtotal,
        'discount': discount,
        'total': total,
        'paymentMethod': paymentMethod,
      };

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      items: ((json['items'] as List?) ?? const [])
          .map((item) =>
              SaleItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
    );
  }
}

class SaleAdapter extends TypeAdapter<Sale> {
  @override
  final int typeId = 204;

  @override
  Sale read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < count; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Sale(
      id: fields[0] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(fields[1] as int),
      items: (fields[2] as List).cast<SaleItem>(),
      subtotal: fields[3] as double,
      discount: fields[4] as double,
      total: fields[5] as double,
      paymentMethod: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Sale obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp.millisecondsSinceEpoch)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.subtotal)
      ..writeByte(4)
      ..write(obj.discount)
      ..writeByte(5)
      ..write(obj.total)
      ..writeByte(6)
      ..write(obj.paymentMethod);
  }
}
