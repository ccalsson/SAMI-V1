abstract class TenantDocument {
  const TenantDocument({this.id, required this.tenantId});

  final String? id;
  final String tenantId;

  Map<String, dynamic> toMap();
}
