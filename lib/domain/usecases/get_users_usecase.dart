import 'package:sami_app/domain/entities/user.dart';
import 'package:sami_app/domain/repositories/user_repository.dart';

class GetUsersUseCase {
  const GetUsersUseCase(this._repository);

  final UserRepository _repository;

  Future<List<User>> call() => _repository.getUsers();
}
