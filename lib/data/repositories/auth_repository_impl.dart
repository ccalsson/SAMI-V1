import 'package:sami_app/core/utils/app_exception.dart';
import 'package:sami_app/core/utils/password_hasher.dart';
import 'package:sami_app/data/models/user_model.dart';
import 'package:sami_app/data/sources/local/hive_local_storage.dart';
import 'package:sami_app/data/sources/local/mock_seed_service.dart';
import 'package:sami_app/domain/entities/user.dart';
import 'package:sami_app/domain/repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._storage, this._passwordHasher, this._seedService)
      : _uuid = const Uuid();

  final HiveLocalStorage _storage;
  final PasswordHasher _passwordHasher;
  final MockSeedService _seedService;
  final Uuid _uuid;

  @override
  Future<void> ensureSeeded() => _seedService.seed();

  @override
  Future<int> failedAttempts(String username) async {
    final Map<String, dynamic>? raw =
        _storage.box(HiveLocalStorage.usersBox).get(username);
    if (raw == null) {
      return 0;
    }
    final model = UserModel.fromMap(raw);
    return model.failedAttempts;
  }

  @override
  Future<void> incrementFailedAttempts(String username) async {
    final usersBox = _storage.box(HiveLocalStorage.usersBox);
    final Map<String, dynamic>? raw = usersBox.get(username);
    if (raw == null) {
      return;
    }
    final model = UserModel.fromMap(raw);
    final updated = model.copyWith(failedAttempts: model.failedAttempts + 1);
    await usersBox.put(username, updated.toMap());
  }

  @override
  Future<User> login(
      {required String username, required String password}) async {
    await ensureSeeded();
    final usersBox = _storage.box(HiveLocalStorage.usersBox);
    final Map<String, dynamic>? raw = usersBox.get(username);
    if (raw == null) {
      throw AppException('Usuario no encontrado', code: 'user_not_found');
    }
    final model = UserModel.fromMap(raw);
    if (model.failedAttempts >= 3) {
      throw AppException(
        'Cuenta bloqueada temporalmente por intentos fallidos.',
        code: 'locked',
      );
    }

    final isValid =
        await _passwordHasher.verifyPassword(password, model.passwordHash);
    if (!isValid) {
      await incrementFailedAttempts(username);
      throw AppException('Credenciales inválidas', code: 'invalid_credentials');
    }

    final resetModel = model.copyWith(failedAttempts: 0);
    await usersBox.put(username, resetModel.toMap());
    return resetModel.toEntity();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> resetFailedAttempts(String username) async {
    final usersBox = _storage.box(HiveLocalStorage.usersBox);
    final Map<String, dynamic>? raw = usersBox.get(username);
    if (raw == null) {
      return;
    }
    final model = UserModel.fromMap(raw);
    await usersBox.put(username, model.copyWith(failedAttempts: 0).toMap());
  }

  @override
  Future<void> enqueueRegistration(Map<String, String> data) async {
    final requestsBox = _storage.box(HiveLocalStorage.requestsBox);
    await requestsBox.put(
      _uuid.v4(),
      <String, dynamic>{
        'name': data['name'],
        'area': data['area'],
        'phone': data['phone'],
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }
}
