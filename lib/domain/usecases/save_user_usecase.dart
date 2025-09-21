import 'package:sami_app/domain/entities/user.dart';
import 'package:sami_app/domain/repositories/user_repository.dart';

class SaveUserUseCase {
  const SaveUserUseCase(this._repository);

  final UserRepository _repository;

  Future<void> call(User user, {String? password}) =>
      _repository.saveUser(user, password: password);
}
