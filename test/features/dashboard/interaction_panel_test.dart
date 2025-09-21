import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/core/services/sami_api_service.dart';
import 'package:sami_app/domain/entities/user.dart';
import 'package:sami_app/features/dashboard/presentation/views/dashboard_view.dart';
import 'package:sami_app/features/superuser/presentation/providers/ai_profiles_provider.dart';
import 'package:sami_app/services/voice_service.dart';
import 'package:sami_app/services/impl/mock_voice_service.dart';
import 'package:sami_app/shared/models/sami_profile.dart';
import 'package:sami_app/shared/providers/menu_provider.dart';
import 'package:sami_app/shared/services/sami_audio_service.dart';

void main() {
  testWidgets('Interaction panel muestra chat para superuser', (tester) async {
    await tester.pumpWidget(_wrapDashboard(role: UserRole.superuser));
    expect(find.textContaining('Chat con SAMI'), findsOneWidget);
  });

  testWidgets('Interaction panel muestra audio para operario', (tester) async {
    await tester.pumpWidget(_wrapDashboard(role: UserRole.operario));
    expect(find.textContaining('Hablar con SAMI'), findsOneWidget);
  });
}

Widget _wrapDashboard({required UserRole role}) {
  final fakeApi = _FakeApiService();
  final menuProvider = MenuProvider();
  final aiProvider =
      AiProfilesProvider(menuProvider: menuProvider, api: fakeApi);
  aiProvider.organizations = [
    SamiOrganizationProfile(
      id: 'org-demo',
      name: 'Demo',
      activeProfile: 'industry.sawmill',
      voice: 'alloy',
      auditTrail: const [],
    ),
  ];
  menuProvider.updateFor(
      role: role, modules: aiProvider.profiles['industry.sawmill']!.modules);
  aiProvider.selectedOrg = aiProvider.organizations.first;

  return MultiProvider(
    providers: [
      Provider<SamiApiService>.value(value: fakeApi),
      ChangeNotifierProvider<MenuProvider>.value(value: menuProvider),
      ChangeNotifierProvider<AiProfilesProvider>.value(value: aiProvider),
      ChangeNotifierProvider<SamiAudioService>.value(
          value: SamiAudioService(api: fakeApi)),
      Provider<VoiceService>.value(
          value: MockVoiceService(scripts: ['eso nomás'])),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: DashboardInteractionPanel(role: role),
      ),
    ),
  );
}

class _FakeApiService extends SamiApiService {
  _FakeApiService() : super(baseUrl: 'http://localhost:3333/api');

  @override
  Future<String> sendChat(
          {required String orgId,
          required String role,
          required String text}) async =>
      'respuesta demo';

  @override
  Future<Map<String, dynamic>> uploadAudio(
          {required String orgId,
          required String role,
          required String filePath}) async =>
      {'response': 'ok', 'audio': ''};

  @override
  Future<List<SamiOrganizationProfile>> fetchOrganizations() async => const [];

  @override
  Future<SamiOrganizationProfile?> fetchOrganization(String orgId) async =>
      null;

  @override
  Future<List<Map<String, dynamic>>> fetchMenu({required String orgId}) async =>
      const [];
}
