import 'package:hive/hive.dart';

import 'product.dart';

class SaleItem extends HiveObject {
  SaleItem({
    required this.productId,
    required this.name,
    required this.qtyKg,
    required this.unitPrice,
    required this.total,
    required this.unit,
  });

  final String productId;
  final String name;
  final double qtyKg;
  final double unitPrice;
  final double total;
  final ProductUnit unit;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'qtyKg': qtyKg,
        'unitPrice': unitPrice,
        'total': total,
        'unit': unit.name,
      };

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['productId'] as String,
      name: json['name'] as String,
      qtyKg: (json['qtyKg'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      unit: ProductUnit.values.byName(json['unit'] as String? ?? 'kg'),
    );
  }
}

class SaleItemAdapter extends TypeAdapter<SaleItem> {
  @override
  final int typeId = 203;

  @override
  SaleItem read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < count; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SaleItem(
      productId: fields[0] as String,
      name: fields[1] as String,
      qtyKg: fields[2] as double,
      unitPrice: fields[3] as double,
      total: fields[4] as double,
      unit: ProductUnit.values[fields[5] as int],
    );
  }

  @override
  void write(BinaryWriter writer, SaleItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.qtyKg)
      ..writeByte(3)
      ..write(obj.unitPrice)
      ..writeByte(4)
      ..write(obj.total)
      ..writeByte(5)
      ..write(obj.unit.index);
  }
}
