class SuperTenant {
  const SuperTenant({
    required this.id,
    required this.name,
    required this.alias,
    required this.plan,
    required this.status,
    required this.monthlyUsage,
  });

  final String id;
  final String name;
  final String alias;
  final String plan;
  final String status;
  final double monthlyUsage;

  SuperTenant copyWith({
    String? id,
    String? name,
    String? alias,
    String? plan,
    String? status,
    double? monthlyUsage,
  }) {
    return SuperTenant(
      id: id ?? this.id,
      name: name ?? this.name,
      alias: alias ?? this.alias,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      monthlyUsage: monthlyUsage ?? this.monthlyUsage,
    );
  }
}

class ProvisionTemplate {
  const ProvisionTemplate({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

class AgentNode {
  const AgentNode({
    required this.id,
    required this.tenantName,
    required this.status,
    required this.pingMs,
    required this.cpuPercent,
    required this.ramPercent,
  });

  final String id;
  final String tenantName;
  final String status;
  final int pingMs;
  final double cpuPercent;
  final double ramPercent;
}

class CameraNode {
  const CameraNode({
    required this.id,
    required this.tenantName,
    required this.label,
    required this.state,
  });

  final String id;
  final String tenantName;
  final String label;
  final String state;
}
