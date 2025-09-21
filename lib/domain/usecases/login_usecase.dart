import 'package:sami_app/domain/entities/user.dart';
import 'package:sami_app/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<User> call(String username, String password) async {
    return _repository.login(username: username, password: password);
  }
}
