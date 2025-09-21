import 'package:sami_app/data/models/project_model.dart';
import 'package:sami_app/data/sources/local/hive_local_storage.dart';
import 'package:sami_app/domain/entities/project.dart';
import 'package:sami_app/domain/repositories/projects_repository.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  ProjectsRepositoryImpl(this._storage);

  final HiveLocalStorage _storage;

  @override
  Future<Project?> findById(String id) async {
    final Map<String, dynamic>? raw =
        _storage.box(HiveLocalStorage.projectsBox).get(id);
    if (raw == null) {
      return null;
    }
    return ProjectModel.fromMap(raw).toEntity();
  }

  @override
  Future<List<Project>> fetchProjects() async {
    final projectsBox = _storage.box(HiveLocalStorage.projectsBox);
    final projects = projectsBox.values
        .map(ProjectModel.fromMap)
        .map((model) => model.toEntity())
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return projects;
  }
}
