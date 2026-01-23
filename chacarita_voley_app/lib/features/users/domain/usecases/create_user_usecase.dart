import '../entities/user.dart';
import '../repositories/user_repository_interface.dart';

class CreateUserUseCase {
  final UserRepositoryInterface repository;

  CreateUserUseCase(this.repository);

  Future<User> execute(User user) async {
    return await repository.createUser(user);
  }
}