import '../../../core/database/cache_store.dart';
import '../models/project_dto.dart';

class ProjectsLocalDataSource {
  ProjectsLocalDataSource(this._cacheStore);

  final CacheStore _cacheStore;

  static const _projectsType = 'projects';

  Future<void> cacheProjects(List<ProjectDto> projects) async {
    await _cacheStore.saveAll(
      _projectsType,
      projects.map((dto) => dto.toJson()).toList(),
    );
  }

  Future<void> upsertProject(ProjectDto project) async {
    await _cacheStore.saveOne(_projectsType, project.id, project.toJson());
  }

  Future<List<ProjectDto>> loadProjects() async {
    final cached = await _cacheStore.readAll(_projectsType);
    return cached.map(ProjectDto.fromJson).toList();
  }

  Future<ProjectDto?> loadProject(String id) async {
    final cached = await _cacheStore.readOne(_projectsType, id);
    if (cached == null) {
      return null;
    }
    return ProjectDto.fromJson(cached);
  }
}
