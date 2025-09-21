import 'package:flutter/foundation.dart';
import 'package:sami_app/core/services/sami_api_service.dart';
import 'package:sami_app/domain/entities/user.dart';
import 'package:sami_app/shared/models/sami_profile.dart';
import 'package:sami_app/shared/providers/menu_provider.dart';

class AiProfilesProvider extends ChangeNotifier {
  AiProfilesProvider({required this.menuProvider, required this.api});

  final MenuProvider menuProvider;
  final SamiApiService api;

  final Map<String, SamiProfile> profiles = {
    'industry.sawmill': const SamiProfile(
      key: 'industry.sawmill',
      name: 'Aserradero',
      tone: 'técnico, producción y seguridad',
      modules: ['production', 'safety', 'tools', 'fuel'],
      focus: ['rendimiento máquina', 'uso de EPP', 'paradas no programadas'],
      reports: ['OEE', 'm³ procesados', 'desperdicio'],
      ttsVoice: 'alloy',
    ),
    'retail.grocery': const SamiProfile(
      key: 'retail.grocery',
      name: 'Verdulería',
      tone: 'amigable, simple',
      modules: ['sales', 'inventory', 'prices', 'waste'],
      focus: ['ventas por hora', 'rotación', 'merma'],
      reports: ['ticket promedio', 'ventas diarias', 'merma semanal'],
      ttsVoice: 'verse',
    ),
    'construction.earthmoving': const SamiProfile(
      key: 'construction.earthmoving',
      name: 'Movimiento de suelos',
      tone: 'operativo/logístico',
      modules: ['fuel', 'gps', 'attendance', 'tools', 'projects'],
      focus: [
        'combustible',
        'uso de maquinaria',
        'horas hombre',
        'demoras por clima'
      ],
      reports: ['litros/turno', 'costo por proyecto', 'paradas por clima'],
      ttsVoice: 'sage',
    ),
    'forestry': const SamiProfile(
      key: 'forestry',
      name: 'Forestal',
      tone: 'analítico, foco en campo',
      modules: ['inventory', 'gps', 'fuel', 'production'],
      focus: ['extracción de resina', 'censo de árboles', 'logística forestal'],
      reports: ['litros extraídos', 'árboles censados', 'camiones/día'],
      ttsVoice: 'alloy',
    ),
  };

  List<SamiOrganizationProfile> organizations = const [];

  SamiOrganizationProfile? selectedOrg;
  bool loading = false;
  String? error;

  static List<SamiOrganizationProfile> _fallbackOrgs() {
    return [
      SamiOrganizationProfile(
        id: 'org-sawmill',
        name: 'Aserradero Demo',
        activeProfile: 'industry.sawmill',
        voice: 'alloy',
        auditTrail: [
          SamiAuditEntry(
            actor: 'superuser',
            action: 'profile.update',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            metadata: const {'profileKey': 'industry.sawmill'},
          ),
        ],
      ),
      SamiOrganizationProfile(
        id: 'org-grocery',
        name: 'Verdulería Demo',
        activeProfile: 'retail.grocery',
        voice: 'verse',
        auditTrail: [
          SamiAuditEntry(
            actor: 'superuser',
            action: 'profile.update',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            metadata: const {'profileKey': 'retail.grocery'},
          ),
        ],
      ),
    ];
  }

  Future<void> load() async {
    if (loading || organizations.isNotEmpty) return;
    loading = true;
    notifyListeners();
    try {
      final fetched = await api.fetchOrganizations();
      organizations = fetched.isNotEmpty ? fetched : _fallbackOrgs();
      selectedOrg ??= organizations.first;
      await selectOrganization(selectedOrg!, viewerRole: UserRole.superuser);
      error = null;
    } catch (err) {
      error = err.toString();
      organizations = _fallbackOrgs();
      selectedOrg ??= organizations.first;
      await selectOrganization(selectedOrg!, viewerRole: UserRole.superuser);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> selectOrganization(SamiOrganizationProfile org,
      {UserRole viewerRole = UserRole.admin}) async {
    selectedOrg = org;
    final detailed = await api.fetchOrganization(org.id);
    if (detailed != null) {
      selectedOrg = detailed;
      final index = organizations.indexWhere((item) => item.id == org.id);
      if (index >= 0) {
        organizations[index] = detailed;
      }
    }
    final profile = profiles[selectedOrg!.activeProfile];
    if (profile != null) {
      menuProvider.updateFor(role: viewerRole, modules: profile.modules);
    }
    final remoteMenu = await api.fetchMenu(orgId: org.id);
    if (remoteMenu.isNotEmpty) {
      menuProvider.applyRemote(remoteMenu);
    }
    notifyListeners();
  }

  Future<void> applyProfile(String profileKey, {required String actor}) async {
    final org = selectedOrg;
    if (org == null) return;
    final success =
        await api.updateProfile(orgId: org.id, profileKey: profileKey);
    if (!success) {
      error = 'No se pudo actualizar el perfil';
      notifyListeners();
      return;
    }
    org.activeProfile = profileKey;
    final profile = profiles[profileKey];
    if (profile != null) {
      menuProvider.updateFor(
          role: UserRole.superuser, modules: profile.modules);
      org.voice = profile.ttsVoice;
    }
    error = null;
    final refreshed = await api.fetchOrganization(org.id);
    if (refreshed != null) {
      selectedOrg = refreshed;
      final index = organizations.indexWhere((item) => item.id == org.id);
      if (index >= 0) organizations[index] = refreshed;
      final profile = profiles[refreshed.activeProfile];
      if (profile != null) {
        menuProvider.updateFor(
            role: UserRole.superuser, modules: profile.modules);
      }
      final remoteMenu = await api.fetchMenu(orgId: org.id);
      if (remoteMenu.isNotEmpty) {
        menuProvider.applyRemote(remoteMenu);
      }
    } else {
      org.auditTrail.insert(
        0,
        SamiAuditEntry(
          actor: actor,
          action: 'profile.update',
          timestamp: DateTime.now(),
          metadata: {'profileKey': profileKey},
        ),
      );
    }
    notifyListeners();
  }

  Future<void> updateVoice(String voice, {required String actor}) async {
    final org = selectedOrg;
    if (org == null) return;
    final success = await api.updateVoice(orgId: org.id, voice: voice);
    if (!success) {
      error = 'No se pudo actualizar la voz';
      notifyListeners();
      return;
    }
    error = null;
    org.voice = voice;
    final refreshed = await api.fetchOrganization(org.id);
    if (refreshed != null) {
      selectedOrg = refreshed;
      final index = organizations.indexWhere((item) => item.id == org.id);
      if (index >= 0) organizations[index] = refreshed;
      final remoteMenu = await api.fetchMenu(orgId: org.id);
      if (remoteMenu.isNotEmpty) {
        menuProvider.applyRemote(remoteMenu);
      }
    } else {
      org.auditTrail.insert(
        0,
        SamiAuditEntry(
          actor: actor,
          action: 'voice.update',
          timestamp: DateTime.now(),
          metadata: {'voice': voice},
        ),
      );
    }
    notifyListeners();
  }
}
