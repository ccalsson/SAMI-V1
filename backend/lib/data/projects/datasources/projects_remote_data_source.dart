import '../../../core/network/http_client.dart';
import '../models/project_dto.dart';

class ProjectsRemoteDataSource {
  ProjectsRemoteDataSource(this._client);

  final AppHttpClient _client;

  Future<List<ProjectDto>> fetchProjects(Map<String, dynamic> params) async {
    final response = await _client.get<List<dynamic>>(
      '/projects',
      queryParameters: params,
    );
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(ProjectDto.fromJson)
        .toList();
  }

  Future<ProjectDto> getProject(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/projects/$id');
    return ProjectDto.fromJson(response.data ?? const {});
  }

  Future<ProjectDto> createProject(Map<String, dynamic> body) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/projects',
      data: body,
    );
    return ProjectDto.fromJson(response.data ?? const {});
  }

  Future<ProjectDto> updateProject(String id, Map<String, dynamic> body) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/projects/$id',
      data: body,
    );
    return ProjectDto.fromJson(response.data ?? const {});
  }
}
