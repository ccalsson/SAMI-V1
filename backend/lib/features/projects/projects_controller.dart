import 'package:flutter/foundation.dart';

import '../../core/errors/app_error.dart';
import '../../domain/projects/project.dart';
import '../../domain/projects/projects_repository.dart';

class ProjectsController extends ChangeNotifier {
  ProjectsController(this._repository);

  final ProjectsRepository _repository;

  List<Project> _projects = <Project>[];
  bool _loading = false;
  AppError? _error;

  List<Project> get projects => _projects;
  bool get isLoading => _loading;
  AppError? get error => _error;

  Future<void> load({String? status}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _projects = await _repository.fetchProjects(status: status);
    } on AppError catch (error) {
      _error = error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
