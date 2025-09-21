import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sami_app/features/superuser/presentation/models/super_dashboard_models.dart';
import 'package:sami_app/features/superuser/services/super_dashboard_service.dart';

enum SuperDashboardSection {
  clients,
  provisioning,
  monitoring,
  billing,
  backups,
  security,
}

class SuperDashboardProvider extends ChangeNotifier {
  SuperDashboardProvider(this._service) {
    _loadInitialData();
  }

  final SuperDashboardService _service;

  SuperDashboardSection _section = SuperDashboardSection.clients;
  List<SuperTenant> _tenants = const [];
  List<SuperTenant> _filteredTenants = const [];
  List<ProvisionTemplate> _templates = const [];
  List<AgentNode> _agents = const [];
  List<CameraNode> _cameras = const [];
  String? _lastDeviceKey;
  String? _lastInstallerUrl;
  bool _loading = false;

  final TextEditingController nameFilter = TextEditingController();
  final TextEditingController aliasFilter = TextEditingController();
  final TextEditingController planFilter = TextEditingController();
  final TextEditingController statusFilter = TextEditingController();

  SuperDashboardSection get section => _section;
  bool get isLoading => _loading;
  List<SuperTenant> get tenants => _filteredTenants;
  List<ProvisionTemplate> get templates => _templates;
  List<AgentNode> get agents => _agents;
  List<CameraNode> get cameras => _cameras;
  String? get lastDeviceKey => _lastDeviceKey;
  String? get lastInstallerUrl => _lastInstallerUrl;

  void setSection(SuperDashboardSection section) {
    if (_section == section) {
      return;
    }
    _section = section;
    notifyListeners();
  }

  Future<void> _loadInitialData() async {
    _loading = true;
    notifyListeners();
    _tenants = await _service.fetchTenants();
    _filteredTenants = _tenants;
    _templates = await _service.fetchProvisionTemplates();
    _agents = await _service.fetchAgents();
    _cameras = await _service.fetchCameras();
    _loading = false;
    notifyListeners();
  }

  void applyFilters() {
    _filteredTenants = _tenants.where((tenant) {
      final matchesName = _matches(tenant.name, nameFilter.text);
      final matchesAlias = _matches(tenant.alias, aliasFilter.text);
      final matchesPlan = _matches(tenant.plan, planFilter.text);
      final matchesStatus = _matches(tenant.status, statusFilter.text);
      return matchesName && matchesAlias && matchesPlan && matchesStatus;
    }).toList(growable: false);
    notifyListeners();
  }

  bool _matches(String value, String filter) {
    if (filter.trim().isEmpty) {
      return true;
    }
    return value.toLowerCase().contains(filter.toLowerCase());
  }

  Future<void> createTenant({
    required String name,
    required String alias,
    required String plan,
  }) async {
    _loading = true;
    notifyListeners();
    final tenant =
        await _service.provisionTenant(name: name, alias: alias, plan: plan);
    _tenants = [..._tenants, tenant];
    applyFilters();
    _loading = false;
    notifyListeners();
  }

  Future<void> impersonate(String tenantId) async {
    await _service.impersonateTenant(tenantId);
  }

  Future<void> generateInstaller({
    required ProvisionTemplate template,
    required String tenantId,
  }) async {
    _loading = true;
    notifyListeners();
    _lastDeviceKey = await _service.generateDeviceKey(template.id);
    _lastInstallerUrl = await _service.requestInstallerZip(
      templateId: template.id,
      tenantId: tenantId,
    );
    _loading = false;
    notifyListeners();
  }

  String suggestTenantId() {
    final random = Random();
    final adjectives = ['verde', 'azul', 'lunar', 'solar'];
    final nouns = ['pi', 'delta', 'omega', 'nexus'];
    return '${adjectives[random.nextInt(adjectives.length)]}-${nouns[random.nextInt(nouns.length)]}-${random.nextInt(999).toString().padLeft(3, '0')}';
  }

  @override
  void dispose() {
    nameFilter.dispose();
    aliasFilter.dispose();
    planFilter.dispose();
    statusFilter.dispose();
    super.dispose();
  }
}
