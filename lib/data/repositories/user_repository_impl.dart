import 'package:sami_app/core/utils/password_hasher.dart';
import 'package:sami_app/data/models/user_model.dart';
import 'package:sami_app/data/sources/local/hive_local_storage.dart';
import 'package:sami_app/domain/entities/user.dart';
import 'package:sami_app/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._storage, this._passwordHasher);

  final HiveLocalStorage _storage;
  final PasswordHasher _passwordHasher;

  @override
  Future<void> deleteUser(String username) async {
    await _storage.box(HiveLocalStorage.usersBox).delete(username);
  }

  @override
  Future<User?> getByUsername(String username) async {
    final Map<String, dynamic>? raw =
        _storage.box(HiveLocalStorage.usersBox).get(username);
    if (raw == null) {
      return null;
    }
    return UserModel.fromMap(raw).toEntity();
  }

  @override
  Future<List<User>> getUsers() async {
    final usersBox = _storage.box(HiveLocalStorage.usersBox);
    return usersBox.values
        .map(UserModel.fromMap)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<void> saveUser(User user, {String? password}) async {
    final usersBox = _storage.box(HiveLocalStorage.usersBox);
    final Map<String, dynamic>? raw = usersBox.get(user.username);
    var passwordHash = raw != null
        ? UserModel.fromMap(raw).passwordHash
        : await _passwordHasher.hashPassword(password ?? 'Cambio123');
    var failedAttempts =
        raw != null ? UserModel.fromMap(raw).failedAttempts : 0;
    if (password != null) {
      passwordHash = await _passwordHasher.hashPassword(password);
      failedAttempts = 0;
    }
    final model = UserModel.fromEntity(
      user,
      passwordHash: passwordHash,
      failedAttempts: failedAttempts,
    );
    await usersBox.put(user.username, model.toMap());
  }
}
