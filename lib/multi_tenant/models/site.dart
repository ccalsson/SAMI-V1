import 'package:sami_app/multi_tenant/models/tenant_document.dart';

class Site extends TenantDocument {
  const Site({
    super.id,
    required super.tenantId,
    required this.name,
    required this.address,
    this.description,
    this.tags = const <String>[],
  });

  final String name;
  final String address;
  final String? description;
  final List<String> tags;

  factory Site.fromMap(String id, Map<String, dynamic> map) {
    return Site(
      id: id,
      tenantId: map['tenantId'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      description: map['description'] as String?,
      tags: List<String>.from(map['tags'] as List? ?? const []),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tenantId': tenantId,
      'name': name,
      'address': address,
      'description': description,
      'tags': tags,
    };
  }

  Site copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? address,
    String? description,
    List<String>? tags,
  }) {
    return Site(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      tags: tags ?? this.tags,
    );
  }
}
