import 'package:flutter/foundation.dart';

import '../../core/errors/app_error.dart';
import '../../domain/tools/tool.dart';
import '../../domain/tools/tools_repository.dart';

class ToolsController extends ChangeNotifier {
  ToolsController(this._repository);

  final ToolsRepository _repository;

  List<Tool> _tools = <Tool>[];
  bool _loading = false;
  AppError? _error;

  List<Tool> get tools => _tools;
  bool get isLoading => _loading;
  AppError? get error => _error;

  Future<void> load({String? status}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _tools = await _repository.fetchTools(status: status);
    } on AppError catch (error) {
      _error = error;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
