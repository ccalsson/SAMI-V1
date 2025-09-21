class SamiProfile {
  const SamiProfile({
    required this.key,
    required this.name,
    required this.tone,
    required this.modules,
    required this.focus,
    required this.reports,
    required this.ttsVoice,
  });

  final String key;
  final String name;
  final String tone;
  final List<String> modules;
  final List<String> focus;
  final List<String> reports;
  final String ttsVoice;
}

class SamiOrganizationProfile {
  SamiOrganizationProfile({
    required this.id,
    required this.name,
    required this.activeProfile,
    required this.voice,
    required this.auditTrail,
  });

  final String id;
  final String name;
  String activeProfile;
  String voice;
  final List<SamiAuditEntry> auditTrail;

  factory SamiOrganizationProfile.fromJson(Map<String, dynamic> json) {
    return SamiOrganizationProfile(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Organización',
      activeProfile: json['active_profile'] as String? ?? '',
      voice: json['tts_voice'] as String? ?? 'alloy',
      auditTrail: ((json['audit'] as List?) ?? [])
          .map(
              (entry) => SamiAuditEntry.fromJson(entry as Map<String, dynamic>))
          .toList(),
    );
  }

  SamiOrganizationProfile copyWith({String? activeProfile, String? voice}) {
    return SamiOrganizationProfile(
      id: id,
      name: name,
      activeProfile: activeProfile ?? this.activeProfile,
      voice: voice ?? this.voice,
      auditTrail: List<SamiAuditEntry>.from(auditTrail),
    );
  }
}

class SamiAuditEntry {
  SamiAuditEntry({
    required this.actor,
    required this.action,
    required this.timestamp,
    required this.metadata,
  });

  final String actor;
  final String action;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  factory SamiAuditEntry.fromJson(Map<String, dynamic> json) {
    return SamiAuditEntry(
      actor: json['actor'] as String? ?? 'unknown',
      action: json['action'] as String? ?? 'change',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          (json['ts'] as num? ?? 0).toInt(),
          isUtc: false),
      metadata: Map<String, dynamic>.from(json['diff'] as Map? ?? {}),
    );
  }
}
