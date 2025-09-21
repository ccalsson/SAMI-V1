import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/domain/entities/user.dart';
import 'package:sami_app/features/superuser/presentation/providers/ai_profiles_provider.dart';
import 'package:sami_app/shared/models/sami_profile.dart';

class AiProfilesView extends StatefulWidget {
  const AiProfilesView({super.key});

  @override
  State<AiProfilesView> createState() => _AiProfilesViewState();
}

class _AiProfilesViewState extends State<AiProfilesView> {
  SamiOrganizationProfile? _selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<AiProfilesProvider>();
    provider.load();
    if (provider.organizations.isNotEmpty) {
      _selected ??= provider.organizations.first;
      provider.selectOrganization(_selected!, viewerRole: UserRole.superuser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AiProfilesProvider>();
    final profiles = provider.profiles;
    final orgs = provider.organizations;
    if (provider.loading && orgs.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (orgs.isEmpty) {
      return const Scaffold(
          body: Center(child: Text('Sin organizaciones disponibles')));
    }
    final selected = provider.selectedOrg ?? _selected ?? orgs.first;
    final selectedProfile = profiles[selected.activeProfile];

    return Scaffold(
      appBar: AppBar(title: const Text('Perfiles de IA')),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: orgs.length,
              itemBuilder: (context, index) {
                final org = orgs[index];
                final isSelected = org.id == selected.id;
                return ListTile(
                  selected: isSelected,
                  title: Text(org.name),
                  subtitle: Text(
                      'Perfil: ${profiles[org.activeProfile]?.name ?? org.activeProfile}'),
                  onTap: () async {
                    setState(() => _selected = org);
                    await provider.selectOrganization(org,
                        viewerRole: UserRole.superuser);
                  },
                );
              },
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 5,
            child: selectedProfile == null
                ? const Center(child: Text('Perfil no encontrado'))
                : _OrganizationProfileDetail(
                    org: selected,
                    profile: selectedProfile,
                    onApply: (profileKey) =>
                        provider.applyProfile(profileKey, actor: 'superuser'),
                    onVoiceChange: (voice) =>
                        provider.updateVoice(voice, actor: 'superuser'),
                    voices: const ['alloy', 'verse', 'sage'],
                    error: provider.error,
                  ),
          ),
        ],
      ),
    );
  }
}

class _OrganizationProfileDetail extends StatefulWidget {
  const _OrganizationProfileDetail({
    required this.org,
    required this.profile,
    required this.onApply,
    required this.onVoiceChange,
    required this.voices,
    this.error,
  });

  final SamiOrganizationProfile org;
  final SamiProfile profile;
  final Future<void> Function(String profileKey) onApply;
  final Future<void> Function(String voice) onVoiceChange;
  final List<String> voices;
  final String? error;

  @override
  State<_OrganizationProfileDetail> createState() =>
      _OrganizationProfileDetailState();
}

class _OrganizationProfileDetailState
    extends State<_OrganizationProfileDetail> {
  String? _selectedProfileKey;
  String? _selectedVoice;

  @override
  void initState() {
    super.initState();
    _selectedProfileKey = widget.org.activeProfile;
    _selectedVoice = widget.org.voice;
  }

  @override
  void didUpdateWidget(covariant _OrganizationProfileDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.org.id != oldWidget.org.id) {
      _selectedProfileKey = widget.org.activeProfile;
      _selectedVoice = widget.org.voice;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.org.name,
                style: Theme.of(context).textTheme.headlineSmall),
            if (widget.error != null) ...[
              const SizedBox(height: 8),
              Text(widget.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            Text('Perfil activo'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedProfileKey,
              items: context
                  .read<AiProfilesProvider>()
                  .profiles
                  .entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedProfileKey = value),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Aplicar perfil'),
              onPressed: _selectedProfileKey == null
                  ? null
                  : () async {
                      await widget.onApply(_selectedProfileKey!);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil aplicado.')),
                      );
                    },
            ),
            const SizedBox(height: 24),
            Text('Voz de SAMI'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedVoice,
              items: widget.voices
                  .map((voice) =>
                      DropdownMenuItem(value: voice, child: Text(voice)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedVoice = value),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.volume_up),
              label: const Text('Guardar voz'),
              onPressed: _selectedVoice == null
                  ? null
                  : () async {
                      await widget.onVoiceChange(_selectedVoice!);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Voz actualizada.')),
                      );
                    },
            ),
            const SizedBox(height: 24),
            Text('Módulos activos',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.profile.modules
                  .map((module) => Chip(label: Text(module)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Focos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...widget.profile.focus.map((focus) => ListTile(
                  leading: const Icon(Icons.bolt),
                  title: Text(focus),
                )),
            const SizedBox(height: 16),
            Text('KPIs/Reportes',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...widget.profile.reports.map((report) => ListTile(
                  leading: const Icon(Icons.insights),
                  title: Text(report),
                )),
            const SizedBox(height: 24),
            Text('Auditoría', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...widget.org.auditTrail.map((entry) => ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(entry.action),
                  subtitle: Text('${entry.actor} · ${entry.timestamp}'),
                )),
          ],
        ),
      ),
    );
  }
}
