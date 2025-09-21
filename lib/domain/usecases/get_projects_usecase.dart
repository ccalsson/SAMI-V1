import 'package:sami_app/domain/entities/project.dart';
import 'package:sami_app/domain/repositories/projects_repository.dart';

class GetProjectsUseCase {
  const GetProjectsUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<List<Project>> call() => _repository.fetchProjects();
}
