import 'package:hive/hive.dart';

class Product extends HiveObject {
  Product({
    required this.id,
    required this.name,
    required this.emoji,
    required this.pricePerKg,
    this.unit = ProductUnit.kg,
    this.imageUrl,
    this.active = true,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String emoji;
  @HiveField(3)
  final double pricePerKg;
  @HiveField(4)
  final ProductUnit unit;
  @HiveField(5)
  final String? imageUrl;
  @HiveField(6)
  final bool active;

  Product copyWith({
    String? name,
    String? emoji,
    double? pricePerKg,
    ProductUnit? unit,
    String? imageUrl,
    bool? active,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      active: active ?? this.active,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '',
      pricePerKg: (json['pricePerKg'] as num).toDouble(),
      unit: ProductUnit.values.byName(json['unit'] as String? ?? 'kg'),
      imageUrl: json['imageUrl'] as String?,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'pricePerKg': pricePerKg,
        'unit': unit.name,
        'imageUrl': imageUrl,
        'active': active,
      };
}

enum ProductUnit { kg, unit }

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 201;

  @override
  Product read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final count = reader.readByte();
    for (var i = 0; i < count; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      emoji: fields[2] as String,
      pricePerKg: fields[3] as double,
      unit: ProductUnit.values[fields[4] as int],
      imageUrl: fields[5] as String?,
      active: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.emoji)
      ..writeByte(3)
      ..write(obj.pricePerKg)
      ..writeByte(4)
      ..write(obj.unit.index)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.active);
  }
}

class ProductUnitAdapter extends TypeAdapter<ProductUnit> {
  @override
  final int typeId = 202;

  @override
  ProductUnit read(BinaryReader reader) {
    final index = reader.readByte();
    return ProductUnit.values[index];
  }

  @override
  void write(BinaryWriter writer, ProductUnit obj) {
    writer.writeByte(obj.index);
  }
}
