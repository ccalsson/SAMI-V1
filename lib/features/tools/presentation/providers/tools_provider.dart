import 'package:flutter/foundation.dart';
import 'package:sami_app/domain/entities/tool.dart';
import 'package:sami_app/domain/usecases/get_tools_usecase.dart';

class ToolsProvider extends ChangeNotifier {
  ToolsProvider({required GetToolsUseCase getTools}) : _getTools = getTools;

  final GetToolsUseCase _getTools;

  List<Tool> _tools = <Tool>[];
  String _search = '';
  ToolStatus? _status;
  bool _loading = false;

  List<Tool> get tools => _applyFilters();
  bool get isLoading => _loading;
  String get search => _search;
  ToolStatus? get statusFilter => _status;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _tools = await _getTools();
    _loading = false;
    notifyListeners();
  }

  void updateSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setStatus(ToolStatus? status) {
    _status = status;
    notifyListeners();
  }

  List<Tool> _applyFilters() {
    return _tools.where((tool) {
      final matchesSearch = _search.isEmpty ||
          tool.name.toLowerCase().contains(_search.toLowerCase());
      final matchesStatus = _status == null || tool.status == _status;
      return matchesSearch && matchesStatus;
    }).toList();
  }
}
