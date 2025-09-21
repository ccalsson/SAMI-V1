import 'package:sami_app/domain/repositories/user_repository.dart';

class DeleteUserUseCase {
  const DeleteUserUseCase(this._repository);

  final UserRepository _repository;

  Future<void> call(String username) => _repository.deleteUser(username);
}
