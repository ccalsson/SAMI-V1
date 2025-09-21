import 'package:flutter/foundation.dart';
import 'package:sami_app/domain/entities/user.dart';
import 'package:sami_app/domain/usecases/delete_user_usecase.dart';
import 'package:sami_app/domain/usecases/get_users_usecase.dart';
import 'package:sami_app/domain/usecases/save_user_usecase.dart';

class AdminUsersProvider extends ChangeNotifier {
  AdminUsersProvider({
    required GetUsersUseCase getUsers,
    required SaveUserUseCase saveUser,
    required DeleteUserUseCase deleteUser,
  })  : _getUsers = getUsers,
        _saveUser = saveUser,
        _deleteUser = deleteUser;

  final GetUsersUseCase _getUsers;
  final SaveUserUseCase _saveUser;
  final DeleteUserUseCase _deleteUser;

  List<User> _users = <User>[];
  bool _loading = false;

  List<User> get users => _users;
  bool get isLoading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _users = await _getUsers();
    _loading = false;
    notifyListeners();
  }

  Future<void> save(User user, {String? password}) async {
    await _saveUser(user, password: password);
    await load();
  }

  Future<void> delete(String username) async {
    await _deleteUser(username);
    await load();
  }
}
