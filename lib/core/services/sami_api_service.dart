import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:sami_app/shared/models/sami_profile.dart';

class SamiApiService {
  SamiApiService({
    http.Client? client,
    String? baseUrl,
    String? authToken,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ??
            const String.fromEnvironment('SAMI_API_BASE',
                defaultValue: 'http://localhost:3333/api'),
        _authToken = authToken;

  final http.Client _client;
  final String _baseUrl;
  String? _authToken;

  set authToken(String? value) => _authToken = value;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=utf-8',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Future<List<SamiOrganizationProfile>> fetchOrganizations() async {
    try {
      final response =
          await _client.get(Uri.parse('$_baseUrl/orgs'), headers: _headers);
      if (response.statusCode != 200) {
        throw Exception('Status ${response.statusCode}');
      }
      final data = jsonDecode(response.body) as List;
      return data
          .map((json) => SamiOrganizationProfile.fromJson(
              Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<SamiOrganizationProfile?> fetchOrganization(String orgId) async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/orgs/$orgId/profile'), headers: _headers);
      if (response.statusCode != 200) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      json['id'] = orgId;
      return SamiOrganizationProfile.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateProfile(
      {required String orgId, required String profileKey}) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/orgs/$orgId/profile'),
      headers: _headers,
      body: jsonEncode({'profileKey': profileKey}),
    );
    return response.statusCode == 200;
  }

  Future<bool> updateVoice(
      {required String orgId, required String voice}) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/orgs/$orgId/voice'),
      headers: _headers,
      body: jsonEncode({'voice': voice}),
    );
    return response.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> fetchMenu({required String orgId}) async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/orgs/$orgId/menu'), headers: _headers);
      if (response.statusCode != 200) return const [];
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return (json['menu'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [];
    } catch (_) {
      return const [];
    }
  }

  Future<String> sendChat(
      {required String orgId,
      required String role,
      required String text}) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/chat'),
      headers: _headers,
      body: jsonEncode({'orgId': orgId, 'role': role, 'text': text}),
    );
    if (response.statusCode != 200) {
      throw Exception('Chat request failed (${response.statusCode})');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['reply']?['reply']?.toString() ??
        json['reply']?.toString() ??
        '';
  }

  Future<Map<String, dynamic>> uploadAudio({
    required String orgId,
    required String role,
    required String filePath,
  }) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('$_baseUrl/audio/in'));
    if (_authToken != null) {
      request.headers['Authorization'] = 'Bearer $_authToken';
    }
    request.fields['orgId'] = orgId;
    request.fields['role'] = role;
    request.files.add(await http.MultipartFile.fromPath(
      'audio',
      filePath,
      contentType: MediaType('audio', 'wav'),
    ));
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception('Audio request failed (${response.statusCode}): $body');
    }
    return Map<String, dynamic>.from(jsonDecode(body) as Map);
  }
}
