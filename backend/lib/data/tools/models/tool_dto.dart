import '../../../domain/tools/tool.dart';

class ToolDto {
  ToolDto({
    required this.id,
    required this.sku,
    required this.name,
    required this.status,
    required this.location,
    this.thumbnailUrl,
  });

  final String id;
  final String sku;
  final String name;
  final String status;
  final String location;
  final String? thumbnailUrl;

  factory ToolDto.fromJson(Map<String, dynamic> json) {
    return ToolDto(
      id: json['id'].toString(),
      sku: json['sku'] as String? ?? '',
      name: json['name'] as String? ?? '',
      status: (json['status'] as String? ?? 'available').toLowerCase(),
      location: json['location'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sku': sku,
        'name': name,
        'status': status,
        'location': location,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      };

  Tool toDomain() {
    return Tool(
      id: id,
      sku: sku,
      name: name,
      status: ToolStatus.values.firstWhere(
        (value) => value.name == status,
        orElse: () => ToolStatus.available,
      ),
      location: location,
    );
  }

  static ToolDto fromDomain(Tool tool) {
    return ToolDto(
      id: tool.id,
      sku: tool.sku,
      name: tool.name,
      status: tool.status.name,
      location: tool.location,
    );
  }
}
