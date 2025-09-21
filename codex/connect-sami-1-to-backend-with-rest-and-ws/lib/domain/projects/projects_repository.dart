import 'project.dart';

abstract class ProjectsRepository {
  Future<List<Project>> fetchProjects({String? query, String? status});
  Future<Project> getProject(String id);
  Future<Project> createProject(Project project);
  Future<Project> updateProject(String id, Map<String, dynamic> updates);
}
