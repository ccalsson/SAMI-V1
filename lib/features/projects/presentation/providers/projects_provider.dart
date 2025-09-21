import 'package:flutter/foundation.dart';
import 'package:sami_app/domain/entities/project.dart';
import 'package:sami_app/domain/usecases/get_projects_usecase.dart';

class ProjectsProvider extends ChangeNotifier {
  ProjectsProvider({required GetProjectsUseCase getProjects})
      : _getProjects = getProjects;

  final GetProjectsUseCase _getProjects;

  List<Project> _projects = <Project>[];
  ProjectStatus? _status;
  bool _loading = false;

  List<Project> get projects => _status == null
      ? _projects
      : _projects.where((project) => project.status == _status).toList();
  bool get isLoading => _loading;
  ProjectStatus? get statusFilter => _status;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _projects = await _getProjects();
    _loading = false;
    notifyListeners();
  }

  void setStatus(ProjectStatus? status) {
    _status = status;
    notifyListeners();
  }
}
